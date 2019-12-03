# Font:
# https://portainer.readthedocs.io/en/stable/agent.html
# https://hub.docker.com/_/postgres/

#------------------------------------------------
# Create a container Postgresql
resource "docker_container" "container1" {
  depends_on = [ "docker_image.image1" ],
  name       = "postgresql"
  hostname   = "postgresql"
  image      = "${docker_image.image1.name}"
  dns        = "${var.dns_address}"
  restart    = "always"
  memory     = "${var.container_memory}"
  env        = ["POSTGRES_USER=${var.database_user}",
                "POSTGRES_PASSWORD=${var.database_password}",
                "POSTGRES_DB=${var.database_name}"]
  ports {
    external = "${var.port_postgresql_external}"
    internal = 5432
    protocol = "${var.port_protocol}"
  }
  volumes {
    host_path      = "${var.dir_postgresql_host_path}"
    container_path = "/var/lib/postgresql/data"
    read_only      = "${var.permission_read_only}"
  }
}

# Pull image Postgresql
resource "docker_image" "image1" {
  name         = "postgres"
  keep_locally = true
}

#------------------------------------------------
# Create a container Applivro
resource "docker_container" "container2" {
  depends_on = [
    "docker_container.container1",
    "docker_image.image2" ],
  name       = "applivro"
  hostname   = "applivro"
  image      = "${docker_image.image2.name}"
  dns        = "${var.dns_address}"
  dns_search = "${var.dns_domain_search}"
  restart    = "always"
  memory     = "${var.container_memory}"
  ports {
    external = "${var.port_http_external}"
    internal = 8080
    protocol = "${var.port_protocol}"
  }
}

# Pull image Applivro
resource "docker_image" "image2" {
  name         = "${var.docker_image_app_livro}"
  keep_locally = true
}
