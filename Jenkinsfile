pipeline {
/* Foi iniciado um comentário com múltiplas linhas.
  Este texto será ignorado durante a execução do pipeline.

    #--------------------- TAREFAS REQUISITOS AO PIPELINE --------------------#

    #------PASSOS A SEREM EXECUTADOS APENAS NO 1º BUILD ------------------#
    1) Você precisa adicionar uma nova credencial com os IDs:
       'meu-acesso-git-teste',

    Acesse a interface web do Jenkins e clique no menu:
    Jenkins Dashboard -> Credentials -> System.
    Em seguida, clique em 'Global credentials (unrestricted)' e depois clique
    em: 'Add Credentials'. Apenas a instrução meu-acesso-git-teste deve ser do tipo
    'Gitlab API Token'. Será necessário instalar os plugins: Gogs, Gitlab e Gitlab Hook
    no Jenkins.
*/

  // A seção 'agent' define o nome do node cadastrado no Jenkins que poderá
  // executar o pipeline
  // 'any' Qualquer node, inclusive o Jenkins master poderá executar o pipeline
  agent any

  // A seção 'environment' contém a declaração de variáveis usadas no pipeline
  environment {

    // As variáveis de ambiente, preferencialmente devem estar em caixa alta
    // para facilitar a diferenciação das palavras reservadas do pipeline.

    // Aspas simples servem para unificar o texto.
    WORKSPACE_DIR = pwd()
    HOST          = 'ci-server.domain.com.br'
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
          git credentialsId: 'meu-acesso-git-teste', branch: 'master',
            url: "http://$HOST/root/jenkins.git"

          // Verificando se o Checkout foi realizado
          sh "ls -l ${WORKSPACE_DIR}/app/"
        }
      }
    }
    stage('Parallel Stage') {
      failFast true
      parallel {
        stage('Branch A') {
          steps {
            echo "On Branch A"
          }
        }
        stage('Branch B') {
          steps {
            echo "On Branch B"
          }
        }
      }
    }
  }
}
