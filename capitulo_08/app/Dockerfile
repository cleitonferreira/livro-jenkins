FROM ubuntu:18.04
# Imagem base

# Informacoes sobre a imagem
LABEL mantenedor="Aécio Pires" \
      autor="Aécio Pires" \
      email="aeciopires@gmail.com" \
      data_criacao="11/08/2018" \
      versao="1.0.0" \
      descricao="Especifica a imagem Docker do App para o livro de Jenkins" \
      licenca="gplv2"

#---------------------------------#
# Variaveis usadas no DockerFile
#---------------------------------#
# As variaveis de ambiente estao declaradas em caixa alterado.
# O valor pode ser alterado na inicializacao do conteiner.
# Se nada for informado, cada uma recebera um valor padrao determinado a seguir.

# Nome do ambiente em que o servico sera executado
ARG NAME_ENVIRONMENT
ENV NAME_ENVIRONMENT ${NAME_ENVIRONMENT:-prod}

# Carrega as configuracoes do microsservico de acordo com a branch de
# configuracao: master, development
ARG BRANCH_CONFIG
ENV BRANCH_CONFIG ${BRANCH_CONFIG:-master}

# Versao do microsservico
ARG APP_VERSION
ENV APP_VERSION ${APP_VERSION:-0.2.0}

# Habilita a inicializacao do microsservico em mode debug
ARG ENABLE_DEBUG
ENV ENABLE_DEBUG ${ENABLE_DEBUG:-false}

# Define o limite minimo em MB da memoria da JVM
ARG MEMORY_JVM
ENV MEMORY_JVM ${MEMORY_JVM:-512}

# Define a URL base de download do pacote da aplicacao
ARG APP_DOWNLOAD_URL
ENV APP_DOWNLOAD_URL ${APP_DOWNLOAD_URL:-http://ci-server.domain.com.br:8081/repository/empresa_teste/com/domain/applivro/}

# Variaveis locais
ARG debug_port=5005
ARG app_port_http=8080
ARG app_port_https=443
ARG app_source_file=applivro-${APP_VERSION}.jar
ARG app_file=applivro.jar
ARG app_download=$APP_DOWNLOAD_URL/$APP_VERSION/$app_source_file
#----------- FIM-VARIAVEIS--------#

# Criando a estrutura de diretorios
RUN mkdir -p /home/livro/app /home/livro/app/log

# Instalando dependencias de software para o build da imagem
RUN apt-get update \
    && apt-get install -y wget openjdk-8-jdk

# Baixando o app
RUN cd /tmp \
    && wget --no-check-certificate ${app_download} -O /tmp/${app_source_file}

# Instalando o app
RUN mv /tmp/${app_source_file} /home/livro/app/${app_file}

# Copiando os arquivos de configuracao do microsservico
COPY conf /home/livro/app/

# Atribuindo as permissoes de acesso
RUN groupadd -r -g 60000 livro \
    && useradd -u 60000 -g 60000 livro \
    && chown -R livro:livro /home/livro/ \
    && chmod -R 755 /home/livro/

# Copiando arquivos e scripts para dentro da imagem
COPY run.sh /run.sh

# Definindo a permissao do scripts e arquivos
RUN chown root:root /run.sh \
    && chmod 755 /run.sh \
    && ldconfig

# Expondo a porta do servico
EXPOSE ${app_port_http}
EXPOSE ${app_port_https}
EXPOSE ${debug_port}

# Iniciando o servico ao iniciar o conteiner
ENTRYPOINT ["/bin/bash", "-c", "/run.sh $BRANCH_CONFIG $ENABLE_DEBUG $NAME_ENVIRONMENT $MEMORY_JVM"]
