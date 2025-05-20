Write-Host "Проверка доступности Docker..." -ForegroundColor Cyan
docker-compose up -d redis redisinsight backend frontend nginx