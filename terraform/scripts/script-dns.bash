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
#sudo set +x
