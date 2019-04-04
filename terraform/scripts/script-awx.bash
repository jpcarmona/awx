### Creación fichero log
#sudo exec > >(sudo tee /var/log/user-data.log|sudo logger -t user-data -s 2>/dev/console) 2>&1
### Activamos "loggeo"
#sudo set -x
## Actualizamos
sudo apt update
sudo apt upgrade -y
##Añadimos repositorio Docker
sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable' -y
sudo apt update
## Instalamos Docker
sudo apt install docker-ce python3 python -y
#sudo systemctl stop systemd-resolved
#sudo systemctl disable systemd-resolved
#sudo systemctl mask systemd-resolved
#sudo rm /etc/resolv.conf
#echo 'nameserver 127.0.0.1' | sudo tee --append /etc/resolv.conf
#echo 'nameserver 8.8.8.8' | sudo tee --append /etc/resolv.conf
sudo adduser ubuntu docker

git clone https://github.com/ansible/awx.git

cd awx/installer

cat << EOF > inventory
localhost ansible_connection=local ansible_python_interpreter="/usr/bin/env python"
[all:vars]
dockerhub_base=ansible
awx_task_hostname=awx
awx_web_hostname=awxweb
postgres_data_dir=/var/tmp/awx/pgdocker
host_port=80
use_docker_compose=true
docker_compose_dir=./
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
project_data_dir=/var/tmp/awx/projects
#awx_container_search_domains=example.com
#ca_trust_dir=/etc/pki/ca-trust/source/anchors
EOF

ansible-playbook -i inventory install.yml
#set +x
