# Проверка наличия параметров
if ($args.Count -lt 1) {
    Write-Host "Использование: $($MyInvocation.MyCommand.Name) <игра> [время_на_старт] [время_на_ход]"
    Write-Host "Пример: $($MyInvocation.MyCommand.Name) ticTacToe 10 5"
    exit 1
}

# Параметры
$GAME_KEY = $args[0]
$START_CLOCK = if ($args.Count -ge 2) { $args[1] } else { 5 }
$PLAY_CLOCK = if ($args.Count -ge 3) { $args[2] } else { 5 }

# Экспорт переменных для docker-compose
$env:GAME_KEY = $GAME_KEY
$env:START_CLOCK = $START_CLOCK
$env:PLAY_CLOCK = $PLAY_CLOCK

# Write-Host "Выключаем систему"
# docker-compose down

Write-Host "Запуск игры $GAME_KEY (время на старт: $START_CLOCK, время на ход: $PLAY_CLOCK)"
Write-Host "Запуск системы визуализации"
docker-compose up -d redis redisinsight backend frontend nginx

# Запуск MCTS игрока
Write-Host "Запуск MCTS игрока..."
docker-compose up -d mcts-player

# Запуск Random игрока
Write-Host "Запуск Random игрока..."
docker-compose up -d random-player

# Даем игрокам время на инициализацию
Write-Host "Ожидание инициализации игроков (20 секунд)..."
Start-Sleep -Seconds 20

# Запускаем GameServer и ждем его завершения (без -d, чтобы скрипт ждал завершения)
# Запуск GameServer с явной передачей переменных окружения
Write-Host "Запуск GameServer..."
docker-compose up game-server

# После завершения GameServer получаем ID сессии
Write-Host "Получение ID сессии из логов MCTS игрока..."
$logs = docker-compose logs mcts-player
$sessionLine = ($logs | Select-String -Pattern "Created session ID with game" | Select-Object -Last 1).Line

$SESSION_ID = $null
if ($sessionLine -match "Created session ID with game .* (.*)") {
    $SESSION_ID = $matches[1]
}

# Останавливаем контейнеры игроков
Write-Host "Остановка контейнеров игроков..."
docker-compose stop mcts-player random-player

# Выводим ID сессии
if ($SESSION_ID) {
    Write-Host "=========================================="
    Write-Host "ID сессии: $SESSION_ID"
    Write-Host "=========================================="
} else {
    Write-Host "ID сессии не найден"
}