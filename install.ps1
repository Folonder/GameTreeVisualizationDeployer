# load-docker-images.ps1
# Скрипт для загрузки Docker образов из tar-архивов, расположенных в папке ./archives

# Директория с архивами
$archivesDir = "./archives"

# Список архивов для загрузки
$imageArchives = @(
    "backend.tar",
    "frontend.tar",
    "ggp.tar",
    "nginx.tar",
    "redis.tar",
    "redisinsight.tar"
)

# Проверка, что директория с архивами существует
if (-not (Test-Path $archivesDir)) {
    Write-Host "ОШИБКА - Директория $archivesDir не найдена!" -ForegroundColor Red
    exit 1
}

# Проверка, что Docker запущен
Write-Host "Проверка доступности Docker..." -ForegroundColor Cyan
try {
    docker info | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Docker недоступен. Убедитесь, что служба Docker запущена."
    }
}
catch {
    $errorMsg = $_.Exception.Message
    Write-Host "ОШИБКА - $errorMsg" -ForegroundColor Red
    exit 1
}

Write-Host "Docker доступен. Начинаю загрузку образов из $archivesDir..." -ForegroundColor Green
Write-Host ""

# Счетчики для статистики
$successCount = 0
$errorCount = 0
$missingCount = 0

# Загрузка каждого архива
foreach ($archive in $imageArchives) {
    $archivePath = Join-Path -Path $archivesDir -ChildPath $archive
    Write-Host "Проверка наличия архива $archive..." -ForegroundColor Cyan
    
    # Проверка существования файла
    if (Test-Path $archivePath) {
        Write-Host "Загрузка образа из $archivePath..." -ForegroundColor Yellow
        
        try {
            # Загрузка образа
            docker load -i $archivePath
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[УСПЕХ] Образ из $archive успешно загружен" -ForegroundColor Green
                $successCount++
            } else {
                Write-Host "[ОШИБКА] Не удалось загрузить образ из $archive" -ForegroundColor Red
                $errorCount++
            }
        }
        catch {
            $errorMessage = $_.Exception.Message
            # Используем формат строки вместо прямого включения переменных с двоеточием
            $errorString = "[ОШИБКА] При обработке {0} - {1}" -f $archive, $errorMessage
            Write-Host $errorString -ForegroundColor Red
            $errorCount++
        }
    }
    else {
        Write-Host "[ОТСУТСТВУЕТ] Файл $archivePath не найден" -ForegroundColor Red
        $missingCount++
    }
    
    Write-Host ""
}

# Вывод итоговой статистики
Write-Host "=== ИТОГИ ЗАГРУЗКИ ОБРАЗОВ ===" -ForegroundColor Cyan
Write-Host "Успешно загружено - $successCount" -ForegroundColor Green
if ($errorCount -gt 0) {
    Write-Host "Ошибок загрузки - $errorCount" -ForegroundColor Red
}
if ($missingCount -gt 0) {
    Write-Host "Не найдено архивов - $missingCount" -ForegroundColor Red
}

# Вывод списка доступных образов после загрузки
Write-Host ""
Write-Host "Список доступных Docker образов" -ForegroundColor Cyan
docker images

Write-Host ""
Write-Host "Загрузка образов завершена." -ForegroundColor Green