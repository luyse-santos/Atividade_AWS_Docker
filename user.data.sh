#!/bin/bash

# Instalar o docker
yum update -y
yum install docker -y
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

# Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
mv /usr/local/bin/docker-compose  /usr/bin/docker-compose

# Montagem do EFS
sudo yum install amazon-efs-utils -y
mkdir /mnt/efs
echo "fs-01a6dc054d2a0ef2c.efs.us-east-1.amazonaws.com:/ /mnt/efs efs defaults,_netdev 0 0" >> /etc/fstab

# Docker-compose.yml
cat <<EOF > /mnt/efs/docker-compose.yml
version: '3'
services:
  wordpress:
    image: wordpress
    restart: always
    ports:
      - 80:80
    environment:
      WORDPRESS_DB_HOST: wordpress.c9864yeam5m4.us-east-1.rds.amazonaws.com
      WORDPRESS_DB_NAME: wordpress
      WORDPRESS_DB_USER: admin
      WORDPRESS_DB_PASSWORD: wordpress
EOF

cd /mnt/efs
docker-compose up -d
