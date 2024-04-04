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
- Na console pesquise por `VPC` > clique em `Criar VPC`.
- Selecione `VPC e muito mais.`
- Deixe as `Configurações padrão.`
- Selecione `2 para as AZs e para as sub-redes públicas e privadas.`
- Em gateways Nat > selecione `1 AZ.`
- Clique em `Criar vpc.`
## 2.Criando grupo de segurança 
- Vá para `ec2`
- No menu esquerdo em `Rede e segurança` > selecione `Security Groups`
- No canto superior da tela clique em `Criar grupo de segurança`
- Crie um nome , uma descrição e use a `VPC criada anteriormente`
- Para o Grupo de segurança da `ec2 e do RDS`
 - Em `Regras de entrada` adicione:

| Tipo              | Protocolo | Intervalo de portas | Origem     | Descrição |
|-------------------|-----------|----------------------|------------|-----------|
| SSH               | TCP       | 22                   | próprio SG | SSH       |
| https             | TCP       | 443                  | 0.0.0.0/0  | HTTPS     |
| NFS               | TCP       | 2049                 | 0.0.0.0/0  | NFS       |
| MYSQL/Aurora      | TCP       | 3306                 | próprio SG | DB        |
| http              | TCP       | 80                   | grupo do LB| HTTP      |
- Clique em "Criar grupode segurança"
- Repita o mesmo processo para `Criar o grupo de segurança do load balancer`
 - Em `Regras de entrada` adicione:
   
| Tipo              | Protocolo | Intervalo de portas | Origem     | Descrição |
|-------------------|-----------|----------------------|------------|-----------|
| http              | TCP       | 80                  | 0.0.0.0/0 | HTTP       |
## 3.Criando o RDS
- Na aba de pesquisa da aws pesquise por `RDS`
- No menu esquerdo selecione `Banco de dados` > `Criar banco de dados`
- Em metodo de criação de dados selecione a opção `Criação padrão`
- Em `Opção de mecanismo` selecione o `MYSQL`
- No `Modelos` escolha selecione o `Nivel gratuito`
- Nas configurações de credenciais:
   - Crie um nome de `Usuário Principal`
   - Selecione `Self managed`
   - Crie uma `Master password e confirme`
- Desabilite a `Escalabilidade automática do armazenamento`
- Em conectividade:
   - Selecione `Não se conectar a um recurso de computação do EC2`
   - Escolha a `VPC criada anteriormente`
   - Para o acesso ao público escolha `Não`
   - Em `Grupo de segurança` selecione o `Security group da ec2`
- Para a autenticação do banco de dados selecioe `Autenticação de senha`
- Configurações adicionais:
   - Em opções de banco de dados `Crie um nome`
   - Desabilite o `backup e a criptografia`
     
   **Nas demais configurações deixe padrão** 
- Clique em `criar banco de dados`
## 4.Criando sistema de arquivos EFS
  - Na console aws pesquise por `EFS`
  - No menu esquerdo clique em `Sistema de arquivos` > `Criar sistema de arquivos`
  - Selecione a `VPC criada`
  - clique em `Criar`
## 5.Criar um modelo de execução 
- Em `Instacias` na ec2
- Clique em `Modelos de execução` > `Criar modelo de execução` 
- Nomeie o modelo de execução 
- Selecione a opção `Orientação sobre o Auto Scaling`
  - Imagens de aplicação - Amazon Linux 2
  - Tipo de instância - t2.micro
  - Escolha um par de chave ou crie um
- Configurações de rede:
  - Em sub-rede selecione `Não incluir no modelo de execução`
  - Firewall > Selecione o `Grupo de segurança da ec2`
- Detalhes avançados:
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
echo "<NOME_DNS_DO_EFS>:/ /mnt/efs efs defaults,_netdev 0 0" >> /etc/fstab

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
# Use as informações do Banco de dados criado anteriormenete
      WORDPRESS_DB_HOST:
      WORDPRESS_DB_NAME: 
      WORDPRESS_DB_USER: 
      WORDPRESS_DB_PASSWORD: 
EOF

cd /mnt/efs
docker-compose up -d
```
  **Nas demais configurações deixe padrão**
- Clique em `Criar modelo de execução`
## 6.Criar um grupo de destino
- Vá para `balanceamento de carga` e clique em `Grupos de destino`> `Criar grupo de destino`
- Em Configuração básica:
   - Para o tipos de destino escolha `Instâncias`
   - Dê um nome ao `Grupo de destino`
   - Selecione a `VPC criada`
   - 
  **Nas demais configurações deixe padrão** 
- Clique em "Próximo" e depois em "Criar grupo de destino"
## 7.Criar o Balanceador de carga
- Ainda em balanceamento de carga vá para "Load balancers" > "criar Load balancers"
- Tipos de load balancer:
   - Application Load Balancer criar
- Configuração básica:
    - Nomeie o load balancer
- Mapeamento de rede:
    - Escolha a `VPC criada`
- Grupos de segurança:
    - Escolha o `Grupo de segurança do LB`
- Listeners e roteamento:
    - Selecione  `Grupo de destino criado anteriormente`
      
   **Nas demais configurações deixe padrão** 
- Clique em `criar Load balancer`
## 8.Criar Grupo Auto Scaling
- Ainda em ec2 , no menu esquerdo vá para Auto Scaling
- Clique em criar grupo de auto scaling
- Crie um Nome para o grupo do Auto Scaling
- Modelo de execução:
   - Selecione o modelo criado
- Clique em próximo
- Rede:
   - Selecione a `VPC criada`
- Zonas de disponibilidade e sub-redes
   - Selecione apenas as `VPC privadas`
- Clique em próximo
- Balanceamento de carga:
   - Selecione `Anexar a um balanceador de carga existente`
- Em Anexar a um balanceador de carga existente:
   - Anexe o `Grupo de destino criado anteriormente`
- Clique em próximo
- Em `Configurar tamanho do grupo e ajuste de escala`
- Tamanho do grupo > Capacidade desejada = 2
- Escalabilidade:
   - Capacidade mínima desejada = 1
   - Capacidade máxima desejada = 3
     
   **Nas demais configurações deixe padrão**
- Clique em `Próximo` para as demais páginas e depois em `Criar grupo de auto scaling`
## 9.Acessar o WordPress 
- Vá até o Load balancer e selecione `LB criado`
- Copie o `Nome do DNS`
- Cole no navegador e acesse o WordPress 
  
