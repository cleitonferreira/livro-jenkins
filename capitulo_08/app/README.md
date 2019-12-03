# Instruções para baixar e compilar a imagem Docker

## Configurações prévias

Instale o PostgreSQL com os comandos a seguir, apenas uma vez.

No Ubuntu com Docker instalado:

```sh
mkdir -p /docker/postgresql/data
chown -R 999:999 /docker/postgresql/data

docker run -d -p 5432:5432 \
  --name postgresql \
  -v /docker/postgresql/data:/var/lib/postgresql/data  \
  -e POSTGRES_PASSWORD=livro \
  -e POSTGRES_USER=livro \
 -e POSTGRES_DB=livro \
  postgres
```

## Compile a imagem Docker para o microsserviço.

Considerando que você já realizou as configurações prévias, use o
comando a seguir para gerar uma imagem do microsserviço para determinada versão.

```sh
cd docker_app/

VERSAO=0.2.0

docker build --build-arg APP_VERSION=$VERSAO -t livro_jenkins/app:$VERSAO .
```

Envie a imagem para o Docker Hub com os comandos abaixo.

```sh
docker login -u CONTA_DOCKER_HUB -p SENHA

docker tag livro_jenkins/app:$VERSAO
docker push livro_jenkins/app:$VERSAO
```

## Inicie o conteiner.

Use o comando a seguir para iniciar um conteiner do microsserviço de acordo com
o ambiente:

----------------
Desenvolvimento:
----------------

```sh
docker run -d -p 8080:8080 -p 443:443 \
--name app \
-e NAME_ENVIRONMENT="dev" \
livro_jenkins/app:$VERSAO
```

------------
Homologação:
------------

```sh
docker run -d -p 80:8080 -p 443:443 \
--name app \
-e NAME_ENVIRONMENT="homolog" \
livro_jenkins/app:$VERSAO
```

---------
Produção:
---------

```sh
docker run -d -p 80:8080 -p 443:443 \
--name app \
-e NAME_ENVIRONMENT="prod" \
livro_jenkins/app:$VERSAO
```

## Visualize o log do microsserviço.

```sh
docker logs -f app
```

## Se precisar remover o conteiner, use o comando abaixo.

```sh
docker rm -f app
```

## Reiniciando o conteiner no boot ou em caso de falha.

```sh
docker update --restart always app
```

## Acesso ao microsserviço.

Acesse o microsserviço através da URL http://IP-SERVER
ou http://IP-SERVER:8080.
