# Atividade_AWS_Docker
Atividade do estágio Compass.UOL
## Requisitos da atividade
1. instalação e configuração do
DOCKER ou CONTAINERD no
host EC2;
_Ponto adicional para o trabalho_
utilizar a instalação via script de
Start Instance (user_data.sh)
2. Efetuar Deploy de uma aplicação
Wordpress com:
container de aplicação
RDS database Mysql
3. configuração da utilização do
serviço EFS AWS para estáticos
do container de aplicação
Wordpress
4. configuração do serviço de Load
Balancer AWS para a aplicação
Wordpress

**Pontos de atenção:**
- Não utilizar ip público
para saída do serviços
WP (Evitem publicar o
serviço WP via IP
Público)
- sugestão para o tráfego de
internet sair pelo LB
(Load Balancer Classic)
- pastas públicas e estáticos
do wordpress sugestão de
utilizar o EFS (Elastic
File Sistem)
- Fica a critério de cada
integrante usar Dockerfile
ou Dockercompose;
- Necessário demonstrar a
aplicação wordpress
funcionando (tela de
login)
- Aplicação Wordpress
precisa estar rodando na
porta 80 ou 8080;
- Utilizar repositório git
para versionamento;
- Criar documentação.
## 1.Criando a VPC
- Na console pesquise por VPC > clique em Criar VPC.
- Selecione "VPC e muito mais."
- Deixe as "configurações padrão."
- Selecione 2 para as AZs e para as sub-redes públicas e privadas.
- Em gateways Nat > em uma AZ.
- Clique em "criar vpc."
## 2.Criando grupo de segurança
- Vá para ec2
- No menu esquerdo em rede e segurança ,selecione "Security Groups"
- No canto superior da tela clique em "Criar grupo de segurança"
- Crie um nome , uma descrição e use a "VPC criada anteriormente"
- Em regras de entrada adicione:

| Tipo              | Protocolo | Intervalo de portas | Origem     | Descrição |
|-------------------|-----------|----------------------|------------|-----------|
| SSH               | TCP       | 22                   | próprio SG | SSH       |
| http              | TCP       | 80                   | 0.0.0.0/0  | HTTP      |
| https             | TCP       | 443                  | 0.0.0.0/0  | HTTPS     |
| NFS               | TCP       | 2049                 | 0.0.0.0/0  | NFS       |
| MYSQL/Aurora      | TCP       | 3306                 | próprio SG | DB        |

- Clique em "Criar grupode segurança"

## 3.Criando o RDS
- Na aba de pesquisa da aws pesquise por "RDS'
- No menu esquerdo selecione "Banco de dados" > "Criar banco de dados"
- Em metodo de criação de dados selecione a criação padrão
- Em opção de mecanismo selecione o MYSQL
- No modelos escolha selecione o "nivel gratuito"
- Nas configurações de credenciais:
   - Crie um nome de "usuário Principal"
   - Selecione "self managed"
   - Crie uma master password e confirme
- Desabilite a "escalabilidade automática do armazenamento"
- Em conectividade:
   - Selecione "Não se conectar a um recurso de computação do EC2"
   - Escolha a "VPC criada anteriormente"
   - Para o acesso ao público escolha "não"
   - Em "Grupo de segurança" selecione o "security group criado anteriormente"
- Para a autenticação do banco de dados selecioe "autenticação de senha" 
- Configurações adicionais:
   - Em opções de banco de dados "crie um nome"
   - Desabilite o backup e a criptografia
- (nas demais configurações deixe padrão) 
- Clique em "criar banco de dados"
## 4.Criar um modelo de execução 
- Em instacias na ec2
- Clique em modelos de execução > criar modelo de execução 
- Nomeie o modelo de execução 
- Selecione a opção "Orientação sobre o Auto Scaling"
 - Imagens de aplicação - Amazon Linux 2
 - Tipo de instância - t2.micro
 - escolha um par de chave ou crie um
- Configurações de rede
  - Em sub-rede selecione "não incluir no modelo de execução"
  - Firewall > Selecione o "grupo de segurança criado anteriomente"
- Detalhes avançados
   - Vá até dados do usuário e insira o script:
```
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
```
- (nas demais configurações deixe padrão) 
- Clique em "Criar modelo de execução"
## 5.Criar um grupo de destino
- vá para balanceamento de carga e clique em grupos de destino > criar grupo de destino
- em Configuração básica:
   - para o tipos de destino escolha "instâncias"
   - de um nome ao grupo de destino
   - selecione a "VPC criada"
- (nas demais configurações deixe padrão) 
- clique em "próximo" e depois em "criar grupo de destino"
## 6.Criar o Balanceador de carga
- ainda em balanceamento de carga vá para "Load balancers" > "criar Load balancers"
- Tipos de load balancer:
   - Application Load Balancer criar
- Configuração básica:
    - nomeie o load balancer
- Mapeamento de rede
    - escolha a "VPC criada"
- Grupos de segurança:
    - escolha o "grupo de segurança criado"
- Listeners e roteamento:
    - selecione  "grupo de destino criado anteriormente"
- (nas demais configurações deixe padrão) 
- clique em criar Load balancer
## 7.criar Grupo Auto Scaling
- Ainda em ec2 , no menu esquerdo vá para Auto Scaling
- Clique em criar grupo de auto scaling
- Crie um Nome para o grupo do Auto Scaling
- Modelo de execução:
   - Selecione o modelo criado
- Clique em próximo
- Rede:
   - Selecione a vpc criada
- Zonas de disponibilidade e sub-redes
   - Selecione apenas as VPC privadas
- Clique em próximo
- Balanceamento de carga:
   - Selecione Anexar a um balanceador de carga existente
- Em Anexar a um balanceador de carga existente:
   - Anexe o Grupo de destino griado anteriormente
- Clique em próximo
- Em Configurar tamanho do grupo e ajuste de escala
- Tamanho do grupo > Capacidade desejada = 2
- Escalabilidade
   - Capacidade mínima desejada = 1
   - Capacidade máxima desejada = 3
- (Nas demais configurações deixe padrão) 
- Clique em próximo para as demais páginas e depois em Criar grupo de auto scaling
## 8.Acassar o WordPress 
- Vá até o Load balancer e selecione o "lb criado"
- Copie o "Nome do DNS"
- Cole no navegador e acesse o WordPress 
  
