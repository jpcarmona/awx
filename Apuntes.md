# Instalación AWX

## Preparando entorno

```bash
sudo apt update

sudo apt -y install apt-transport-https ca-certificates curl \
software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
| sudo apt-key add -

sudo add-apt-repository -y "deb [arch=amd64] \
https://download.docker.com/linux/ubuntu bionic stable"

sudo apt update

sudo apt-get install docker-ce python3-venv

PROJECT="local_awx"

PROJECT_DIR="${HOME}/$PROJECT"

mkdir $PROJECT_DIR

git clone https://github.com/ansible/awx.git $PROJECT_DIR/repo_awx

# Opcional para los logos
git clone https://github.com/ansible/awx-logos.git $PROJECT_DIR/awx-logos

python3 -m venv $PROJECT_DIR/entorno_awx

source $PROJECT_DIR/entorno_awx/bin/activate

pip install ansible docker docker-compose
```

## Configuración 

```bash
cd $PROJECT_DIR/repo_awx/installer

cp $PROJECT_DIR/repo_awx/installer/inventory $PROJECT_DIR/repo_awx/installer/inventory.old

cat << EOF > inventory
localhost ansible_connection=local ansible_python_interpreter="/usr/bin/env python"
[all:vars]
dockerhub_base=ansible
awx_task_hostname=awx
awx_web_hostname=awxweb
    # Directorio persistente de la base de datos
postgres_data_dir=/var/tmp/awx/pgdocker
#
host_port=80
    # Necesario usando docker-compose
use_docker_compose=true
docker_compose_dir=$PROJECT_DIR
#
pg_username=awx
pg_password=awxpass
pg_database=awx
pg_port=5432
rabbitmq_password=awxpass
rabbitmq_erlang_cookie=cookiemonster
admin_user=admin
admin_password=password
create_preload_data=False
secret_key=awxsecret
    # Para guardar en local la carpeta de proyectos
project_data_dir=/var/tmp/awx/projects
#
    # Para esteblecer nombre de dominio en "search"
#awx_container_search_domains=example.com
#
    # Para utilizar nuestros propios certificados
#ca_trust_dir=/etc/pki/ca-trust/source/anchors
#
    # Para utilizar logos en ../../awx-logos
#awx_official=true
#
EOF

ansible-playbook -i inventory install.yml
```

----------------------------------------------------------------------

## Uso básico de la API

* Obtener tipos de recursos disponibles:
```bash
TOWERHOST="localhost"
curl -s -k http://${TOWERHOST}/api/v2/ | jq
```

* Obtener un token mediante usuario y contraseña:
```bash
TOWERHOST="localhost"
USER="admin"
PASS="password"
curl -ku ${USER}:$PASS -H "Content-Type: application/json" -X POST \
-d '{"description":"Tower CLI", "application":null, "scope":"write"}' \
http://${TOWERHOST}/api/v2/users/1/personal_tokens/ | jq '.token,.expires'
```

* Obtener un recurso autenticado mediante token:
```bash
TOWERHOST="localhost"
TOKEN="H2shHvTZwZP9MQmSlQpcStiZ3FmRwe"
curl -k -H "Authorization: Bearer ${TOKEN}" \
-H "Content-Type: application/json" \
-X POST  -d '{}' http://${TOWERHOST}/api/v2/job_templates/5/launch/ | jq
```

-----------------------------------------------------------------------

## Creación de contenedor Docker mediante ansible

```bash
PROJECT="local_awx"

PROJECT_DIR="${HOME}/$PROJECT"

source $PROJECT_DIR/entorno_awx/bin/activate

mkdir -p $PROJECT_DIR/ansible_docker/docker
```

* Dockerfile:
```bash
cat << EOF > $PROJECT_DIR/ansible_docker/docker/Dockerfile
FROM ventz/bind
EXPOSE 53
EOF
```

* Inventory:
```bash
cat << EOF > $PROJECT_DIR/ansible_docker/hosts_test.yml
---
all:
  hosts:
    test:
      ansible_host: 127.0.0.1
      ansible_connection: local
...
EOF
```

* Playbook:
```bash
cat << EOF > $PROJECT_DIR/ansible_docker/playbook.yml
---
- hosts: test
  tasks:
    - name: Build Docker image from Dockerfile
      docker_image:
        name: awx_dns
        path: docker
        state: build

    - name: Running the container
      docker_container:
        name: awx_dns_master
        image: awx_dns:latest
        state: started
...
EOF
```

* Ejecutar Playbook:
```bash
ansible-playbook -i $PROJECT_DIR/ansible_docker/hosts_test.yml $PROJECT_DIR/ansible_docker/playbook.yml
```

* Para que aparezca en proyectos de AWX(WEB):
```bash
docker exec -it installer_web_1 mkdir -p /var/lib/awx/projects/proyecto1
docker cp $PROJECT_DIR/ansible_docker/playbook.yml installer_web_1:/var/lib/awx/projects/proyecto1/
docker cp $PROJECT_DIR/ansible_docker/docker installer_web_1:/var/lib/awx/projects/proyecto1/
```

* Para que se ejecute en awx(TASK):
```bash
docker exec -it installer_task_1 mkdir -p /var/lib/awx/projects/proyecto1
docker cp $PROJECT_DIR/ansible_docker/playbook.yml installer_task_1:/var/lib/awx/projects/proyecto1/
docker cp $PROJECT_DIR/ansible_docker/docker installer_task_1:/var/lib/awx/projects/proyecto1/
```

----------------------------------------------------------------------

## Prueba de ejecución plantillas para el dns ya montado con el docker-compose ya montado también

* Docker-compose:
```bash
cat << EOF > $PROJECT_DIR/docker-compose_old.yml
version: '2'
services:

  web:
    image: ansible/awx_web:3.0.1
    networks:
      bind-dhcp-awx:
        ipv4_address: 172.20.0.3
    depends_on:
      - rabbitmq
      - memcached
      - postgres
    ports:
      - "80:8052"
    hostname: awxweb
    user: root
    restart: unless-stopped
    environment:
      http_proxy:
      https_proxy:
      no_proxy:
      SECRET_KEY: awxsecret
      DATABASE_NAME: awx
      DATABASE_USER: awx
      DATABASE_PASSWORD: awxpass
      DATABASE_PORT: 5432
      DATABASE_HOST: postgres
      RABBITMQ_USER: guest
      RABBITMQ_PASSWORD: guest
      RABBITMQ_HOST: rabbitmq
      RABBITMQ_PORT: 5672
      RABBITMQ_VHOST: awx
      MEMCACHED_HOST: memcached
      MEMCACHED_PORT: 11211
      AWX_ADMIN_USER: admin
      AWX_ADMIN_PASSWORD: password

  task:
    image: ansible/awx_task:3.0.1
    networks:
      bind-dhcp-awx:
        ipv4_address: 172.20.0.4
    depends_on:
      - rabbitmq
      - memcached
      - web
      - postgres
    hostname: awx
    user: root
    restart: unless-stopped
    environment:
      http_proxy:
      https_proxy:
      no_proxy:
      SECRET_KEY: awxsecret
      DATABASE_NAME: awx
      DATABASE_USER: awx
      DATABASE_PASSWORD: awxpass
      DATABASE_HOST: postgres
      DATABASE_PORT: 5432
      RABBITMQ_USER: guest
      RABBITMQ_PASSWORD: guest
      RABBITMQ_HOST: rabbitmq
      RABBITMQ_PORT: 5672
      RABBITMQ_VHOST: awx
      MEMCACHED_HOST: memcached
      MEMCACHED_PORT: 11211
      AWX_ADMIN_USER: admin
      AWX_ADMIN_PASSWORD: password

  rabbitmq:
    image: ansible/awx_rabbitmq:3.7.4
    networks:
      bind-dhcp-awx:
        ipv4_address: 172.20.0.5
    restart: unless-stopped
    environment:
      RABBITMQ_DEFAULT_VHOST: awx
      RABBITMQ_ERLANG_COOKIE: cookiemonster

  memcached:
    image: memcached:alpine
    networks:
      bind-dhcp-awx:
        ipv4_address: 172.20.0.6
    restart: unless-stopped

  postgres:
    image: postgres:9.6
    networks:
      bind-dhcp-awx:
        ipv4_address: 172.20.0.7
    restart: unless-stopped
    volumes:
      - /opt/awx/var/lib/postgresql/data:/var/lib/postgresql/data:Z
    environment:
      POSTGRES_USER: awx
      POSTGRES_PASSWORD: awxpass
      POSTGRES_DB: awx
      PGDATA: /var/lib/postgresql/data/pgdata

# dns servers
  dns1:
    image: docker-registry.emergya.com:443/emergya/emergya-docker-bind9:latest
    container_name: dns1
    networks:
      bind-dhcp-awx:
        ipv4_address: 172.20.0.2
      bind-dhcp-awx1:
        ipv4_address: 172.21.0.2
    volumes:
      - $HOME:$HOME
  dns2:
    image: docker-registry.emergya.com:443/emergya/emergya-docker-bind9:latest
    container_name: dns2
    networks:
      bind-dhcp-awx:
        ipv4_address: 172.20.0.8
      bind-dhcp-awx1:
        ipv4_address: 172.21.0.3
    volumes:
      - $HOME:$HOME
  dns3:
    image: docker-registry.emergya.com:443/emergya/emergya-docker-bind9:latest
    container_name: dns3
    networks:
      bind-dhcp-awx:
        ipv4_address: 172.20.0.9
      bind-dhcp-awx1:
        ipv4_address: 172.21.0.4
    volumes:
      - $HOME:$HOME
networks:
  bind-dhcp-awx:
    ipam:
      config:
        - subnet: 172.20.0.0/16
  bind-dhcp-awx1:
    ipam:
      config:
        - subnet: 172.21.0.0/16
EOF
```

* Ejecución docker-compose:
```bash
docker-compose -f docker-compose_old.yml up -d
```

----------------------------------------------------------------------

## Uso tower-cli

### Instalación y configuración

* Instalación:
```bash
pip install ansible-tower-cli
```

* Variables configuración:
```bash
TOWER_COLOR: color
TOWER_FORMAT: format
TOWER_HOST: host
TOWER_PASSWORD: password
TOWER_USERNAME: username
TOWER_VERIFY_SSL: verify_ssl
TOWER_VERBOSE: verbose
TOWER_DESCRIPTION_ON: description_on
TOWER_CERTIFICATE: certificate
```

* Configuración global:
```bash
tower-cli config --global host http://localhost
tower-cli config --global username admin
tower-cli config --global password password
tower-cli config --global verify_ssl false
```

* Configuración usuario:
```bash
tower-cli config host http://localhost
tower-cli config username admin
tower-cli config password password
tower-cli config verify_ssl false
```

* Establecemos variables para especificar donde vamos a configurar:
```bash
#COnfiguración global
config_tower-cli=/etc/tower/tower_cli.cfg
#COnfiguración usuario
config_tower-cli=~/.tower_cli.cfg
```

* Creamos fichero de configuración:
```bash
cat << EOF > $config_tower-cli
host http://localhost
username admin
password password
verify_ssl = false
EOF
```

### Credenciales con tower-cli

* Listado de credenciales:
```bash
# Formato largo en JSON
tower-cli receive --credential all
# Formato claro y corto
tower-cli credential list
```

* Creación credenciales(tipo maquina-ssh,con clave privada):
```bash
tower-cli credential create --credential-type="Machine" --name="prueba2" --user="admin" --inputs="username: jpcarmona
ssh_key_data: |
  $(cat ~/.ssh/id_rsa | tr '\n' ' ')"
```

* Creación credenciales(tipo github,con clave privada):
```bash
awx_inputs="ssh_key_data: |
$(awk '{printf " %s\n", $0}' < ~/.ssh/id_rsa)"
tower-cli credential create --credential-type="Source Control" --name="credential_2" --user="admin" --inputs="$awx_inputs"  --force-on-exists
```

* Creación credenciales(tipo github,con contraseña):
```bash
tower-cli credential create --credential-type="Source Control" --name="credential_2" --user="admin" --inputs="username: jpcarmona
password: <contraseña>"
```

* Eliminar credencial:
```bash
tower-cli credential delete -n prueba
```

* Modificar credencial:
```bash
tower-cli credential modify -n credential_1 --inputs="username: jpcarmona
ssh_key_data: |
 $(cat ~/.ssh/emergya_ecdsa | tr '\n' ' ')"
```

### Inventarios con tower-cli

* Listado de inventarios:
```bash
# Formato largo en JSON
tower-cli receive --inventory all
# Formato claro y corto
tower-cli inventory list
```

* Creación inventario:
```bash
tower-cli inventory create --name="inventory_1" --organization="Default" --description="example inventory"
```

* Creación inventario con ficheros:
```bash
tower-cli inventory create --name="inventory_1" --organization="Default" --description="example inventory" --variables=@inventory_vars.yml
```

* Eliminar inventario:
```bash
tower-cli inventory delete -n inventory_1
```

* Añadir Servidor a inventario:
```bash
tower-cli host create --name="host_1" --description="example host" --inventory="inventory_1"
```

* Modificar Servidor de un inventario:
```bash
tower-cli host modify --name="host_1" --description="example host" --inventory="inventory_1" --variables="ansible_host: 127.0.0.1"
```

* Añadir fuentes a inventario de un proyecto existente:
```bash
tower-cli inventory_source create --name="source_1" --description="example source" --inventory="inventory_dns" --source="scm" --source-path="inventories/servers" --source-project="proyecto_fuentes"
```

* Actualizar inventario fuente(o utilizar opciones "--update-on-launch=true"):
```bash
tower-cli inventory_source update awx
```

### Proyectos con tower-cli

* Listado de proyectos:
```bash
# Formato largo en JSON
tower-cli receive --project all
# Formato claro y corto
tower-cli project list
```

* Creación proyectos(local):
```bash
# Se necesita plantilla de ansible en /var/lib/awx/projects
sudo mkdir -p /var/tmp/awx/projects/project_1
sudo su -c "cat << EOF > /var/tmp/awx/projects/project_1/playbook.yml
---
- hosts: host_1
  tasks:
    - name: Running the container
      docker_container:
        name: awx_dns
        image: dns_awx:latest
        state: started
...
EOF"

tower-cli project create --name="proyect_1" --organization="Default" --scm-type="manual" --local-path="project_1"
```

* Creación proyectos(git):
```bash
tower-cli project create --name="project_3" --organization="Default" --scm-type="git" --scm-url="https://github.com/Emergya/sistemas-ansible-roles.git" --scm-branch="master" --scm-credential="credential_2"
```

* Eliminar proyectos:
```bash
tower-cli project delete -n prueba
```

### Plantillas con tower-cli

* Listado de plantillas:
```bash
# Formato largo en JSON
tower-cli receive --job_template all
# Formato claro y corto
tower-cli job_template list
```

* Creación plantilla:
```bash
tower-cli job_template create --name="job_template_1" --job-type="run" --inventory="inventory_1" --project="proyect_1" --playbook="playbook.yml" --credential="credential_1"
```

* Eliminar plantillas:
```bash
tower-cli job_template delete -n prueba
```

* Ejecución plantillas:
```bash
tower-cli job_template callback -n job_template_1
```


## Despliegue de insfraestructura AWX en AWS con Terraform

* Para hacer docker login dentro de una instancia en AWS:
```bash
"sudo curl -sL https://raw.githubusercontent.com/Emergya/docker-registry-expect-scripted-login/master/docker-registry-expect-scripted-login -o /usr/local/bin/docker-registry-expect-scripted-login"

"sudo chmod +x /usr/local/bin/docker-registry-expect-scripted-login"

"/bin/bash --login -c 'export DOCKER_REGISTRY_URI=${var.emergya_docker_registry_uri}; export DOCKER_REGISTRY_USER=${var.emergya_docker_registry_user}; export DOCKER_REGISTRY_PASS=${var.emergya_docker_registry_pass}; docker-registry-expect-scripted-login'"
```