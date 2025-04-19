## Визуализация поиска по дереву методом Монте-Карло

##### Исходники проекта:

Frontend: https://github.com/Folonder/GameTreeVisualizationFrontend

Backend: https://github.com/Folonder/GameTreeVisualization

Архивы Docker образов проекта: https://disk.yandex.ru/d/HWxma80fahCTrg

### Запуск проекта в Docker

1. Скачать модули

&emsp; 1.1. Скачать архивы образов Docker

&emsp; 1.2. Выполнить команды для загрузки архивов образов в Docker:
```
docker load -i project-frontend.tar
```
```
docker load -i project-backend.tar
```

2. Запустить систему в Docker в корневой диерктории проекта GameTreeVisualizationDeployer с помощью команды:
```
docker-compose -f docker-compose-deploy.yml up
```

### Запуск проектов из исходников

1. Установить [NodeJS 18.0](https://node-js-org.vercel.app/en/download), [.NET 8.0](https://dotnet.microsoft.com/en-us/download/dotnet/8.0), [Docker Desktop](https://www.docker.com/products/docker-desktop/)
2. Запустить Docker Desktop
3. Выполнить команду для запуска Redis:
```
docker-compose -f docker-compose-redis.yml up
```
4. Перейти в папку GameTreeVisualizationFrontend и выполнить команды:
```
npm install
```
```
npm start
```
5. Перейти в папку ```GameTreeVisualization/GameTreeVisualization.Web``` и выполнить команду:
```
dotnet run
```


### Работа с системой
1. Для запуска GGP Base Package нужно последовательно запустить конфигурации запуска проекта в Intellij IDEA: MCTS_Gamer, Random_Player, GameServerRunnerMany.
2. После этого логи роста дерева будут записаны в Redis. В консоли вывода MCTS_Gamer будет выведена строка подобного содержания. Это ID сессии для ввода на сайте.
```
Created session ID with game 'ticTacToe1x3': ticTacToe1x3_20250328_181618_3308530104260213565
```
3. Посмотреть логи, записанные в Redis можно по ссылке ```http://localhost:5004``` Адрес хранилища Redis: ```redis://default:password@redis:6379 ```
3. Проект доступен по ссылке:
```
http://localhost
```

### Примечение

Примеры логов доступны в папке SampleLogs

