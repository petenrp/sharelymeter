# Docker Installation 
sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf list docker-ce
sudo dnf install docker-ce --nobest -y --allowerasing
sudo systemctl start docker
sudo systemctl enable docker

# Docker Compose Installation
sudo dnf install curl -y
sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose
sudo chmod +x /usr/bin/docker-compose
sudo docker-compose --version

# Firewall Allow http
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --list-all
sudo firewall-cmd --reload

# Set HTTP proxy
sudo setsebool -P httpd_can_network_connect 1

# Make Production Folder
mkdir production
cd production

# Docker up the services
sudo curl -L "https://download1492.mediafire.com/mlhkc9whpgig/yox42o84rhu14si/afternoon-tor-56476.zip" -o ./afternoon-tor-56476.zip
unzip afternoon-tor-56476.zip
cd afternoon-tor-56476
sudo docker-compose up -d
