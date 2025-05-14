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

echo "Выключаем систему"
docker-compose down

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
echo "Ожидание инициализации игроков (30 секунд)..."
sleep 10

# Запуск GameServer
echo "Запуск GameServer..."
docker-compose up -d game-server



# Показываем результаты
echo "Игра завершена. Результаты сохранены в директории matches/"