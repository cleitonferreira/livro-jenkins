pipeline {
/* Foi iniciado um comentário com múltiplas linhas.
  Este texto será ignorado durante a execução do pipeline.

  #--------------------- TAREFAS REQUISITOS AO PIPELINE --------------------#

  #------PASSOS A SEREM EXECUTADOS APENAS NO 1º BUILD ------------------#
  1) Você precisa adicionar uma nova credencial com os IDs:
     'meu-acesso-git-teste',
     'login-docker-hub',

  Acesse a interface web do Jenkins e clique no menu:
  Jenkins Dashboard -> Credentials -> System.
  Em seguida, clique em 'Global credentials (unrestricted)' e depois clique
  em: 'Add Credentials'. Apenas a credencial 'meu-acesso-git-teste' deve ser do tipo
  'Gitlab API Token'. Será necessário instalar os plugins: Gogs, Gitlab e Gitlab Hook
  no Jenkins.

  0) Instale o Docker-CE nos hosts alvos desse pipeline.

  1) Configure a integração entre o Jenkins e cada projeto no GIT usando o
    webhook.
*/

  // A seção 'agent' define o nome do node cadastrado no Jenkins que
  // deverá executar o pipeline
  agent { label 'node-ubuntu'}

  // A seção 'environment' contém a declaração de variáveis usadas no pipeline
  environment {

    // As variáveis de ambiente, preferencialmente devem estar em caixa alta
    // para facilitar a diferenciação das palavras reservadas do pipeline.
    // 'null', significa que variável será iniciada com o valor nulo (vazio)
    LAST_TAG_APP = null
    VERSAO_APP   = null

    // Aspas simples servem para unificar o texto.
    WORKSPACE_DIR         = pwd()
    URL_GIT               = 'http://ci-server.domain.com.br/root/applivro-jenkins.git'
    URL_SONARQUBE         = 'http://ci-server.domain.com.br:9000'
    APPLIVRO_DOWNLOAD_URL = 'http://ci-server.domain.com.br:8081/repository/empresa_teste/com/domain/applivro/'
    DOCKER_REGISTRY       = 'index.docker.io'
    DOCKER_REPOSITORY     = "app_livro_jenkins"
    PROJECT               = 'applivro'
    DIR_TMP               = '/tmp'
    DEPLOY_ENV            = 'prod'
    SENDER                = 'jenkins@domain.com.br'
    MAIL_SYSADMIN         = 'livro@domain.com.br'
    MAIL_TEAM             = 'livro@domain.com.br'
  }

  stages {
    stage('Checkout Project'){
      steps{

        // Usando o 'echo' para exibir uma mensagem
        echo 'Checkout do projeto do Git...'

        // Usando o 'sh' para acessar o shell bash do node para executar comandos
        sh "mkdir -p $WORKSPACE_DIR/app/;"

        // Acessando o diretório de trabalho e executando comandos dentro
        // desse diretório
        dir("${WORKSPACE_DIR}/app/"){

          // Checkout do projeto
          git credentialsId: 'meu-acesso-git-teste', branch: 'master',
            url: "${URL_GIT}"

          // Obtendo a tag atual para uso neste ciclo
          script{
            LAST_TAG_APP = sh(returnStdout: true, script: "git describe --tags `git rev-list --tags --max-count=1`").trim();
          }

          // Obtendo a versão da aplicação a partir do pom.xml
          script{
            VERSAO_APP = sh(returnStdout: true,
                              script: """./mvnw help:evaluate \
                                -Dexpression=project.version | grep -e '^[^\\[]' | tail -n1""").trim()
          }
        }
      }
    }
    stage('Analyze Code') {
      steps{
        dir("${WORKSPACE_DIR}/app/"){
          echo "====> Analisando o código fonte da aplicação web com o SonarQube..."
          sh "./mvnw clean package sonar:sonar -Dsonar.host.url=${URL_SONARQUBE} ; "
        }
      }
    }
    stage('Build App') {
      steps{
        dir("${WORKSPACE_DIR}/app/"){
          echo "====> Compilando a aplicação web para gerar o pacote da versão ${VERSAO_APP} e enviá-lo ao Nexus..."
          sh """./mvnw clean deploy \
                  -Dmaven.wagon.http.ssl.insecure=true \
                  -Dmaven.wagon.http.ssl.allowall=true \
                  -Dmaven.wagon.http.ssl.ignore.validity.dates=true ;
              """
        }
      }
    }
    stage('Build Docker Image') {
      steps {
        // Gerando a imagem Docker para a última versão do microsserviço
        echo "====> Gerando a imagem Docker do APP '${VERSAO_APP}'..."
        dir("${WORKSPACE_DIR}/capitulo_09/app") {
          sh """docker build --network host --build-arg APP_VERSION=$VERSAO_APP \
                --build-arg APP_DOWNLOAD_URL=$APPLIVRO_DOWNLOAD_URL \
                -t livro_jenkins/app:$VERSAO_APP . """
        }
      }
    }
    stage('Send Docker Image') {
      steps {
        echo '-----> Fazendo login no Docker Hub...'

        withCredentials([usernamePassword(credentialsId: 'login-docker-hub',
          passwordVariable: 'DOCKER_HUB_PASS', usernameVariable: 'DOCKER_HUB_USER')]) {

          sh "docker login -u '${DOCKER_HUB_USER}' -p '${DOCKER_HUB_PASS}' "

          echo '-----> Enviando a imagem do App...'
          sh """docker tag livro_jenkins/app:$VERSAO_APP $DOCKER_REGISTRY/$DOCKER_HUB_USER/$DOCKER_REPOSITORY:$VERSAO_APP;
              docker push $DOCKER_REGISTRY/$DOCKER_HUB_USER/$DOCKER_REPOSITORY:$VERSAO_APP"""
        }
      }
    }
    stage('Deploy @Prod') {
      steps {
        echo '+++++> Deploy no ambiente de produção...'
        withCredentials([usernamePassword(credentialsId: 'login-docker-hub',
          passwordVariable: 'DOCKER_HUB_PASS', usernameVariable: 'DOCKER_HUB_USER')]) {

          dir("${WORKSPACE_DIR}/capitulo_09/jenkins_deploy") {
            sh """chmod +x terraform_deploy.sh;
                ./terraform_deploy.sh $DEPLOY_ENV $PROJECT $DOCKER_REGISTRY/$DOCKER_HUB_USER/$DOCKER_REPOSITORY:$VERSAO_APP"""
          }
        }
      }
    }
    stage('Mail to Team') {
      steps {
        mail to: "${MAIL_TEAM}", cc: '', bcc: '',
        from: "${SENDER}",
        subject: "[JENKINS] ${currentBuild.fullDisplayName} - Build ${currentBuild.currentResult}!",
        body: " Build da imagem Docker \
             \n Gerei as imagem Docker para o seguinte app e versão. \
             \n APP => ${VERSAO_APP} \
             \n \
             \n Verifique a qualidade do código fonte no SonarQube: \
             \n URL_SONARQUBE=${URL_SONARQUBE}/projects \
             \n \
             \n Tentei fazer deploy no seguinte ambiente. \
             \n PROJECT    => ${PROJECT} \
             \n DEPLOY_ENV => ${DEPLOY_ENV} \
             \n \
             \n Detalhes da compilação: \
             \n currentBuild.displayName: ${currentBuild.displayName} \
             \n currentBuild.description: ${currentBuild.description} \
             \n currentBuild.currentResult: ${currentBuild.currentResult} \
             \n currentBuild.durationString: ${currentBuild.durationString} "
      }
    }
    stage('Results') {
      steps {
        echo 'Fim do Pipeline... Foi gerado o pacote da aplicação com as seguintes informações'
        echo "PROJECT      => $PROJECT"
        echo "LAST_TAG_APP => $LAST_TAG_APP"
        echo "VERSAO_APP   => $VERSAO_APP"
        echo "URL_GIT      => $URL_GIT"
      }
    }
  }
  post {
    always {
      mail to: "${MAIL_SYSADMIN}", cc: '', bcc: '',
      from: "${SENDER}",
      subject: "${currentBuild.fullDisplayName} - Build ${currentBuild.currentResult}!",
      body: " Build da imagens Docker \
           \n Acesse o Dashboard do Jenkins em ${env.BUILD_URL} para visualizar os resultados. \
           \n \
           \n Tentei gerar a imagem Docker para o seguinte app e versão. \
           \n APP => ${VERSAO_APP} \
           \n \
           \n Verifique a qualidade do código fonte no SonarQube: \
           \n URL_SONARQUBE=${URL_SONARQUBE}/projects \
           \n \
           \n Tentei fazer deploy no seguinte ambiente. \
           \n PROJECT    => ${PROJECT} \
           \n DEPLOY_ENV => ${DEPLOY_ENV} \
           \n \
           \n Detalhes da compilação: \
           \n currentBuild.displayName: ${currentBuild.displayName} \
           \n currentBuild.description: ${currentBuild.description} \
           \n currentBuild.currentResult: ${currentBuild.currentResult} \
           \n currentBuild.duration: ${currentBuild.duration} ms \
           \n currentBuild.durationString: ${currentBuild.durationString} \
           \n NODE_NAME_BUILD: ${env.NODE_LABELS} \
           \n WORKSPACE_DIR: ${WORKSPACE_DIR} \
           \n BRANCH_NAME: ${env.BRANCH_NAME} \
           \n currentBuild.absoluteUrl: ${currentBuild.absoluteUrl}/consoleFull"
    }
  }
}
