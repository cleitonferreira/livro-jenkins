# Informações
# autor: "Aécio Pires"
# email: http://blog.aeciopires.com/contato
# Manifest: livro.pp
#
# Parameters: none
#
# Actions: Instala e configura os pacotes necessários a compilação de aplicaçoes
# através da integração contínua usando o Jenkins
#
# Sample Usage:
#
#  puppet apply livro.pp
#

# Declaração de variáveis
# Postfix
$smtp_server           = '127.0.0.1'
$smtp_port             = '25'
$smtp_banner           = 'carteiro'
$mynetworks            = "127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 ${::ipaddress}"
$relayhost             = ' '
$mydestination         = "localhost.localdomain localhost ${::hostname} ${::fqdn}"
$docker_repo_installed = 'YES'
$puppet_repo_installed = 'YES'
$postfix_service       = 'postfix'
$required_packages     = ['apt-transport-https',
  'ca-certificates',
  'curl',
  'software-properties-common',
  'wget',
  'sudo',
  'vim',
  'git',
  'maven',
  'build-essential',
  'libssl-dev',
  'gcc',
  'make',
  'openjdk-8-jdk',
  'unzip',
  'postfix',
  'mutt', ]

if $::operatingsystem == 'ubuntu' {

  case $::operatingsystemmajrelease {
    '18.04': {
      # Configurando o acesso ao repositório do Docker
      exec { 'repository_docker':
        command  => 'true; \
          cd /tmp; \
          curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - ; \
          add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"; \
          apt-get update; \
          echo "YES" > /tmp/.install.DOCKER_REPO; ',
        onlyif   => "result=\"\$(cat /tmp/.install.DOCKER_REPO;)\"; \
          test \"\$result\" != \"${docker_repo_installed}\" ; ",
        provider => 'shell',
        path     => ['/usr/local/sbin', '/usr/local/bin','/usr/sbin','/usr/bin','/sbin','/bin'],
        timeout  => '14400', #tempo em segundos equivalente a 4 horas
        require  => Package[$required_packages],
      }
    }
    default: {
      # fail é uma função padrão do Puppet
      fail("[ERRO] Nao sei instalar os pacotes nesta distro.")
    }
  }
}
else{
  # fail é uma função padrão do Puppet
  fail("[ERRO] Nao sei instalar os pacotes nesta distro.")
}

# Criando o usuário livro
user { 'livro':
  ensure   => 'present',
  comment  => 'user livro,,,',
  groups   => ['livro', 'sudo', 'vagrant',],
  home     => '/home/livro',
  #A senha é: livro
  password => '$6$LyFI6Js1$/jopKYrVoUmfuGvfz54Q6eoZTyqf6X//WcGCQgdcqD919V..isRDr2dbCw2P2Z8V2mbIZ.miWavHu/GgRb9xC/',
  shell    => '/bin/bash',
  require  => [ Group['livro'],
    Group['sudo'],
    Package[$required_packages], ],
}

# Criando alguns grupos para o usuário livro
group { 'livro':
  ensure => present,
}

group { 'sudo':
  ensure => present,
}

# Criando o diretório HOME do usuário livro
file { '/home/livro':
  ensure  => directory,
  mode    => '0644',
  owner   => livro,
  group   => livro,
  require => User['livro'],
}

# Instalando os pacotes requeridos
package { $required_packages:
  ensure => present,
}

# Atualizando o pacote do Puppet-Agent e Puppet-Bolt
package { ['puppet-agent',
  'bolt']:
  ensure => latest,
}

# Instalando a versão mais recente do docker-ce
package { 'docker-ce':
  ensure  => latest,
  require => Exec['repository_docker'],
}

# Iniciando o serviço Docker
service { 'docker':
  ensure  => 'running',
  require => Package['docker-ce'],
}

# Adicionando no grupo docker os usuários vagrant e livro
exec { 'users_group_docker':
  command  => 'true; \
    usermod -aG docker vagrant; \
    setfacl -m user:vagrant:rw /var/run/docker.sock; \
    usermod -aG docker livro; \
    setfacl -m user:livro:rw /var/run/docker.sock; ',
  provider => 'shell',
  path     => ['/usr/local/sbin', '/usr/local/bin','/usr/sbin','/usr/bin','/sbin','/bin'],
  timeout  => '14400', #tempo em segundos equivalente a 4 horas
  require  => [ Package['docker-ce'],
    User['livro'], ],
}

# Iniciando o serviço Postfix
service { $postfix_service:
   ensure     => 'running',
   enable     => true,
   hasrestart => true,
   hasstatus  => true,
   require    => Package['postfix'],
 }

# Gerenciando o arquivo de configuração do Postfix
file { '/etc/postfix/main.cf':
  ensure  => 'file',
  notify  => Service[$postfix_service],
  #content => template("main.cf.erb"),
  mode    => '0744',
  owner   => 'root',
  group   => 'root',
  require => Package['postfix'],
}

# Adicionando registros no arquivo /etc/hosts
# para resolução de nome das VMs
host { 'ci-server.domain.com.br':
  ensure       => present,
  host_aliases => 'ci-server',
  ip           => '192.168.56.10',
}

host { 'node-ubuntu.domain.com.br':
  ensure       => present,
  host_aliases => 'node-ubuntu',
  ip           => '192.168.56.11',
}

host { 'prod.domain.com.br':
  ensure       => present,
  host_aliases => 'prod',
  ip           => '192.168.56.12',
}
