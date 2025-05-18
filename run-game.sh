#!/bin/bash

# Проверка наличия параметров
if [ $# -lt 1 ]; then
    echo "Использование: $0 <игра> [время_на_старт] [время_на_ход]"
    echo "Пример: $0 ticTacToe 10 5"
    exit 1
fi

# Параметры
GAME_KEY=$1
START_CLOCK=${2:-5}
PLAY_CLOCK=${3:-5}

# Экспорт переменных для docker-compose
export GAME_KEY
export START_CLOCK
export PLAY_CLOCK

# echo "Выключаем систему"
# docker-compose down

echo "Запуск игры $GAME_KEY (время на старт: $START_CLOCK, время на ход: $PLAY_CLOCK)"
echo "Запуск системы визуализации"
docker-compose up -d redis redisinsight backend frontend nginx

# Запуск MCTS игрока
echo "Запуск MCTS игрока..."
docker-compose up -d mcts-player

# Запуск Random игрока
echo "Запуск Random игрока..."
docker-compose up -d random-player

# Даем игрокам время на инициализацию
echo "Ожидание инициализации игроков (10 секунд)..."
sleep 20

# Запускаем GameServer и ждем его завершения (без -d, чтобы скрипт ждал завершения)
# Запуск GameServer с явной передачей переменных окружения
echo "Запуск GameServer..."
docker-compose up game-server

# После завершения GameServer получаем ID сессии
echo "Получение ID сессии из логов MCTS игрока..."
SESSION_ID=$(docker-compose logs mcts-player | grep "Created session ID with game" | tail -1 | sed -n 's/.*Created session ID with game .* \(.*\)/\1/p')

# Останавливаем контейнеры игроков
echo "Остановка контейнеров игроков..."
docker-compose stop mcts-player random-player

# Выводим ID сессии
if [ -n "$SESSION_ID" ]; then
    echo "===========================================" 
    echo "ID сессии: $SESSION_ID"
    echo "===========================================" 
else
    echo "ID сессии не найден"
fi