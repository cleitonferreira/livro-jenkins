# Português

1. Este diretório contém o arquivo ``template.tf`` que define as configurações
de acesso remoto ao Docker e de autenticação no Docker Registry. Ele contém
também o arquivo ``variables.tf`` onde você pode definir os valores das variáveis
usadas pelo ``template.tf``.
2. O subdiretório ``modules/application`` possui o arquivo ``application.tf``
que define a criação dos conteineres applivro e postgresql. Ele contém também o
arquivo ``variables.tf`` onde você pode definir os valores das variáveis usadas
pelo ``application.tf``.
3. Altere os valores de acordo com a necessidade.
4. O objetivo é instalar o applivro e disponibilizar o acesso na porta 8080/TCP
do host que executa o conteiner.
5. O arquivo ``graph.png`` mostra o relacionamento entre os recursos gerenciados
pelo Terraform.

Comandos mais usados:

* terraform --help    => Exibe a ajuda do comando terraform<br>
* terraform providers => Imprime a árvore de providers usados na configuração<br>
* terraform init      => Inicializa o diretório de trabalho do Terraform<br>
* terraform validate  => Valida a sintaxe dos arquivos do Terraform<br>
* terraform plan      => Gera e exibe o plano de execução (mas não altera nada) <br>
* terraform apply     => Compila e altera a infraestrutura conforme o planejado<br>
* terraform show      => Inspeciona e exibe o estado atual ou planejado da infraestrutura<br>
* terraform destroy   => Destroi a infraestrutura gerenciada pelo Terraform<br>
