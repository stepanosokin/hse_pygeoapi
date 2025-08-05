1) в my.config.yml прописать системные переменные в разделе server
```
server:
    bind:
        host: ${API_HOST}   # для Yandex.Cloud Serverless Containers задать API_HOST=<URL контейнера> при создании ревизии
        port: ${API_PORT}   # для Yandex.Cloud задать API_PORT=80 при создании ревизии
    url: http://${API_HOST}:${API_PORT}
```

2) создать образ pygeoapi:
Dockerfile:
```
FROM geopython/pygeoapi:latest

RUN apt update
RUN apt install wget
RUN mkdir -p ~/.postgresql && wget "https://storage.yandexcloud.net/cloud-certs/CA.pem" --output-document ~/.postgresql/root.crt && chmod 0655 ~/.postgresql/root.crt

COPY ./my.config.yml /pygeoapi/local.config.yml

ENV PG_HOST=my.fake.yandex.host
ENV PG_PORT=0000
ENV PG_DB=myfakedb
ENV PG_USER=myfakeuser1
ENV PG_PASS=myfakepassword
ENV API_HOST=localhost
ENV API_PORT=5000
```
сборка образа:
docker build -t cr.yandex/<id реестра контейнеров Yandex>/hse-pygeoapi:latest --platform=linux/amd64 .

отправка образа в Yandex Container Registry
docker push cr.yandex/<id реестра контейнеров Yandex>/hse-pygeoapi:latest

2) В Serverless Containers создать контейнер. При создании ревизии:
1. выбрать режим HTTP Server
2. указать минимум 1 vCPU, минимум 20% доступности, минимум 1024 МБ памяти
3. указать загруженный образ pygeoapi
4. задать переменные окружения:
API_HOST = имя хоста контейнера. Он отобразится после создания первой ревизии
API_PORT = 80
CONTAINER_PORT = 8080 # здесь по идее надо как-то брать значение из переменной PORT, но сделать это так и не получилось. Так что пробуем указывать дефолтное значение, которое подсмотрели на youtube https://www.youtube.com/live/OVFAjzGDU5w?si=YdRqXlfKIqS2BKs0.
PG_HOST = имя хоста Postgresql (доступное)
PG_PORT = номер порта сервера Postgresql, который будет использоваться как источник
PG_DB = название базы postgresql
PG_USER = пользователь postgres
PG_PASS = пароль postgres

любые переменные можно задать с помощью секретов YandexLockbox, но для этого сервисный аккаунт должен иметь привилегию lockbox.payloadViewer

сервисный аккаунт - это аккаунт, от имени которого будет запускаться кантейнер. выбрать существующий или создать новый, у которого есть нужные привилегии:
container-registry.images.puller
managed-postgresql.viewer
lockbox.payloadViewer

и другие в зависимости от конфигурации

здесь еще поле для экспериментов:
таймаут - 30 сек
количество одновременных вызовов экземпляров - 4
количество подготовленных экземпляров - 2




