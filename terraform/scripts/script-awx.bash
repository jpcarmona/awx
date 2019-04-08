if [ "$1" == "init" ]
then
## Actualizamos
sudo apt-get update
sudo apt-get upgrade -y
##Añadimos repositorio Docker
sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable' -y
sudo apt-get update
## Instalamos Docker
sudo apt-get install -y docker-ce python3-pip
#sudo systemctl stop systemd-resolved
#sudo systemctl disable systemd-resolved
#sudo systemctl mask systemd-resolved
#sudo rm /etc/resolv.conf
#echo 'nameserver 127.0.0.1' | sudo tee --append /etc/resolv.conf
#echo 'nameserver 8.8.8.8' | sudo tee --append /etc/resolv.conf
sudo adduser ubuntu docker
elif [ "$1" == "awx" ]
then
sudo apt-get install -y git ansible docker-compose
git clone https://github.com/ansible/awx.git
cat << EOF > awx/installer/inventory
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
ansible-playbook -i awx/installer/inventory awx/installer/install.yml
elif [ "$1" == "dns" ]
then
sudo apt-get install -y python python-pip
pip install docker-py
fi
