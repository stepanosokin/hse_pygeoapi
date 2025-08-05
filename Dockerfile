FROM geopython/pygeoapi:latest

RUN apt update
RUN apt install wget
RUN mkdir -p ~/.postgresql && wget "https://storage.yandexcloud.net/cloud-certs/CA.pem" --output-document ~/.postgresql/root.crt && chmod 0655 ~/.postgresql/root.crt

COPY ./my.config.yml /pygeoapi/local.config.yml

# ARG MY_API_PORT

ENV PG_HOST=my.fake.yandex.host
ENV PG_PORT=0000
ENV PG_DB=myfakedb
ENV PG_USER=myfakeuser1
ENV PG_PASS=myfakepassword
ENV API_HOST=localhost
ENV API_PORT=5000
# ENV API_PORT=${PORT}