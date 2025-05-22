variable "image_name" {
  default = "pienaahj/jasperserver"
}

variable "platforms" {
  default = ["linux/amd64", "linux/arm64"]
}

variable "JRS_DB_TYPE" {
  default = "postgres"
}

variable "JRS_DB_HOST" {
  default = "postgres"
}

variable "JRS_DB_PORT" {
  default = "5432"
}

variable "JRS_DB_NAME" {
  default = "jasperserver"
}

variable "JRS_DB_USER" {
  default = "jasper"
}

variable "JRS_DB_PASSWORD" {
  default = "jasper"
}

group "default" {
  targets = ["jasperserver"]
}

target "jasperserver" {
  context = "."
  dockerfile = "Dockerfile"
  tags = ["${image_name}:latest"]
  platforms = platforms
  args = {
    JRS_DB_TYPE      = JRS_DB_TYPE
    JRS_DB_HOST      = JRS_DB_HOST
    JRS_DB_PORT      = JRS_DB_PORT
    JRS_DB_NAME      = JRS_DB_NAME
    JRS_DB_USER      = JRS_DB_USER
    JRS_DB_PASSWORD  = JRS_DB_PASSWORD
  }
}