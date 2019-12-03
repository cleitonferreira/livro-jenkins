#-------------------------
# Changes the values default of accord with the necessity
#-------------------------

variable "docker_image_app_livro" {
  description = "Docker image applivro."
  default = "aeciopires/app_livro_jenkins:0.3.2"
}

variable "database_user" {
  description = "Database user."
  default = "livro"
}

variable "database_password" {
  description = "Database password."
  default = "livro"
}

variable "database_name" {
  description = "Database name."
  default = "livro"
}

variable "database_address" {
  description = "Database address."
  default = "172.17.0.1"
}

variable "dns_address" {
  description = "List of IP address DNS servers."
  default = ["8.8.8.8"]
}

variable "dns_domain_search" {
  description = "List of DNS domain name search."
  default = ["domain.com.br"]
}

variable "container_memory" {
  description = "Limit max in MB of memory of containers."
  default = 512
}

variable "port_postgresql_external" {
  description = "Port external of container."
  default = 5432
}

variable "port_http_external" {
  description = "Port HTTP external of container."
  default = 8080
}

variable "port_protocol" {
  description = "Protocol of container ports."
  default = "TCP"
}

variable "dir_postgresql_host_path" {
  description = "Path of directory of Docker Host to files storage of container. If not exists, will creat by terraform."
  default = "/docker/postgresql/data"
}

variable "permission_read_only" {
  description = "Access permission in directory of Docker Host. If false, read and write. If true, read only."
  default = false
}
