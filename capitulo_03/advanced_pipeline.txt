pipeline {
/* Foi iniciado um comentário com múltiplas linhas.
  Este texto será ignorado durante a execução do pipeline.

  Comentários de uma única são iniciados com //
*/

  // A seção 'agent' define o nome do node cadastrado no Jenkins que poderá
  // executar o pipeline
  // 'any' Qualquer node, inclusive o Jenkins master poderá executar o pipeline
  agent any

  // A seção 'environment' contém a declaração de variáveis usadas no pipeline
  environment {

    // As variáveis de ambiente, preferencialmente devem estar em caixa alta
    // para facilitar a diferenciação das palavras reservadas do pipeline.
    // 'null', significa que variável será iniciada com o valor nulo (vazio)
    VERSAO_REGISTRY = null

    // Aspas simples servem para unificar o texto.
    WORKSPACE_DIR      = pwd()
    URL_SONARQUBE      = 'http://ci-server.domain.com.br:9000'
    PROJECT            = 'app_livro'
    DEPLOY_TEST_ENV    = 'test'
    DEPLOY_HOMOLOG_ENV = 'homolog'
    DIR_HOSTFILE       = '/home/jenkins/'
    DIR_TMP            = '/tmp'
    MAIL_SYSADMIN      = 'aeciopires@gmail.com'
    MAIL_TEAM          = 'desenv@domain.com.br'

    // Aspas duplas servem para concatenar nome de variáveis e texto.
    // As variáveis são referenciadas começando com $ e o nome entre {}
    HOSTFILE = "${DIR_HOSTFILE}/${PROJECT}_${DEPLOY_TEST_ENV}.txt"
  }

  stages {
    stage('Checkout Projects'){
      steps{

        // Usando o 'echo' para exibir uma mensagem
        echo 'Checkout do projeto do Git...'

        // Usando o 'sh' para acessar o shell bash do node para executar comandos
        sh "mkdir -p $WORKSPACE_DIR/app/;"

        // Acessando o diretório de trabalho e executando comandos dentro
        // desse diretório
        dir("${WORKSPACE_DIR}/app/"){

          // Checkout do projeto
          git branch: 'master',
            url: 'https://github.com/jhipster/jhipster-registry'
       }
      }
    }
    stage('Code_Analysis_Build') {
      // Se houver qualquer falha em um dos stages executados paralelamente
      // o pipeline será interrompido e os stages seguintes não serão executados
      failFast true

      // Executando stages paralelos para ganhar tempo
      parallel{
        stage('App1'){
          steps{
            dir("${WORKSPACE_DIR}/app/"){
              echo 'Simulando a compilação da aplicação 1'
            }
          }
        }
        stage('App2'){
          steps{
            dir("${WORKSPACE_DIR}/app/"){
              echo 'Simulando a compilação da aplicação 2'
            }
          }
        }
        stage('App3'){
          steps{
            dir("${WORKSPACE_DIR}/app/"){
              echo 'Simulando a compilação da aplicação 3'
            }
          }
        }
      }
    }
    stage('Build Docker Images') {
      steps {
        echo 'Simulando a geração de uma imagem Docker de cada app...'
      }
    }
    stage('Send Images') {
      steps {
        echo 'Simulando o envio das imagens Docker para o Hub ou Registry...'
      }
    }
    stage('Deploy') {
      failFast true
      parallel{
        stage('Deploy @Test') {
          steps {
            echo 'Deploy no ambiente de teste...'
          }
        }
        stage('Deploy @Homolog') {
          steps {
            echo 'Deploy no ambiente de homologação...'
          }
        }
      }
    }

    // Se tudo ocorrer com sucesso nos stages anteriores, uma mensagem será enviada
    // ao time de desenvolvimento com cópia para o sysadmin
    stage('Mail to Team') {
      steps {

        // Para compor o conteúdo do email, são referenciados os nomes de variáveis
        // criadas no pipeline (caixa alta) e variáveis do Jenkins (caixa baixa)
        // \n inicia uma nova linha
        // \ permite continuação da instrução na linha seguinte
        mail to: "${MAIL_TEAM}", cc: "${MAIL_SYSADMIN}", bcc: '',
        from: 'jenkins@domain.com.br',
        subject: "[JENKINS] ${currentBuild.fullDisplayName} - Build ${currentBuild.currentResult}!",
        body: " Build da imagens Docker-APP \
             \n Gerei as imagens Docker para os seguintes apps e versões. \
             \n REGISTRY => ${VERSAO_REGISTRY} \
             \n \
             \n Verifique a qualidade do código fonte dos projetos no SonarQube: \
             \n URL_SONARQUBE=${URL_SONARQUBE}/projects \
             \n \
             \n Tentei fazer deploy nos seguintes ambientes. \
             \n PROJECT            => ${PROJECT} \
             \n DEPLOY_TEST_ENV    => ${DEPLOY_TEST_ENV} \
             \n DEPLOY_HOMOLOG_ENV => ${DEPLOY_HOMOLOG_ENV} \
             \n \
             \n \
             \n Detalhes da compilação: \
             \n currentBuild.displayName: ${currentBuild.displayName} \
             \n currentBuild.description: ${currentBuild.description} \
             \n currentBuild.currentResult: ${currentBuild.currentResult} \
             \n currentBuild.durationString: ${currentBuild.durationString} "
      }
    }
  }

  // Se o pipeline der certo ou não, uma mensagem sera enviada ao sysadmin
  // com mais detalhes
  post {
    always {
      mail to: "${MAIL_SYSADMIN}", cc: '', bcc: '',
      from: 'jenkins@domain.com.br',
      subject: "${currentBuild.fullDisplayName} - Build ${currentBuild.currentResult}!",
      body: " Build da imagens Docker-APP \
           \n Acesse o Dashboard do Jenkins em ${env.BUILD_URL} para visualizar os resultados. \
           \n \
           \n Tentei gerar as imagens Docker para os seguintes apps e versoes. \
           \n REGISTRY => ${VERSAO_REGISTRY} \
           \n \
           \n Verifique a qualidade do código fonte dos projetos no SonarQube: \
           \n URL_SONARQUBE=${URL_SONARQUBE}/projects \
           \n \
           \n Tentei fazer deploy nos seguintes ambientes. \
           \n PROJECT            => ${PROJECT} \
           \n DEPLOY_TEST_ENV    => ${DEPLOY_TEST_ENV} \
           \n DEPLOY_HOMOLOG_ENV => ${DEPLOY_HOMOLOG_ENV} \
           \n DIR_HOSTFILE       => ${DIR_HOSTFILE} \
           \n HOSTFILE           => ${HOSTFILE} \
           \n \
           \n \
           \n Detalhes da compilação: \
           \n DIR_TMP                      = ${DIR_TMP} \
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
