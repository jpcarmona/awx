**!IMPORTANTE!**

* Generar una clave SSH en el directorio raiz de este directorio llamado awx

* Para la conexión de ansible a los contenedores es necesario tener en el "HOME" de la instancia el authorized_keys con la clave que usará AWX.

* Needed VAR file:
```
variable "emergya_docker_registry_uri" {
  type    = "string"
  default = "XXXXXXXXXXXX"
}

variable "emergya_docker_registry_user" {
  type    = "string"
  default = "XXXXXXXXXXXX"
}

variable "emergya_docker_registry_pass" {
  type    = "string"
  default = "XXXXXXXXXXXX"
}
```