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
- Selecione VPC e muito mais.
- Deixe as configurações padrão.
- Selecione 2 para as AZs e para as sub-redes públicas e privadas.
- Em gateways Nat > em uma AZ.
- Clique em criar vpc.
## 2.Criando grupo de segurança
- Vá para ec2
- No menu esquerdo em rede e segurança ,selecione Security Groups
- No canto superior da tela clique em criar grupo de segurança
- Crie um nome , uma descrição e use a VPC criada anteriormente
- Em regras de entrada adicione:

| Tipo              | Protocolo | Intervalo de portas | Origem     | Descrição |
|-------------------|-----------|----------------------|------------|-----------|
| SSH               | TCP       | 22                   | próprio SG | SSH       |
| http              | TCP       | 80                   | 0.0.0.0/0  | HTTP      |
| https             | TCP       | 443                  | 0.0.0.0/0  | HTTPS     |
| NFS               | TCP       | 2049                 | 0.0.0.0/0  | NFS       |
| MYSQL/Aurora      | TCP       | 3306                 | próprio SG | DB        |

## 3.Criando o RDS
- na aba de pesquisa da aws pesquise por RDS
- no menu esquerdo selecione Banco de dados > criar banco de dados
- em metodo de criação de dados selecione a criação padrão
- em opção de mecanismo selecione o MYSQL
- modelos escolha o nivel gratuito
- nas configurações de credenciais:
   - crie um nome de usuário orincipal
   - selecione self managed
   - crie uma master password e confirme
- desabilite a escalabilidade automática do armazenamento
- em conectividade:
   - selecione Não se conectar a um recurso de computação do EC2
   - escolha a vpc criada anteriormente
   - para o acesso ao público escolha não
   - emgupo de segurança selecione o security group criado anteriormente
- para a autenticação do banco de dados selecioe autenticação de senha 
- configurações adicionais:
   - em Opções de banco de dados crie um nome
   - desabilite o backup e a criptografia
- (nas demais configurações deixe padrão) 
- crie o banco de dados
## 4. criando um modelo de execução 
- em instacias na ec2
- clique em modelos de execução > criar modelo de execução 
- nomeie o modelo de execução 
- selecione a opção Orientação sobre o Auto Scaling
 - Imagens de aplicação - Amazon Linux 2
 - Tipo de instância - t2.micro
 - escolha um par de chave ou crie um
- Configurações de rede
 - em sub-rede selecione não incluir no modelo de execução
  -  em Firewall > Selecione o grupo de segurança criado anteriomente
    - em detalhes avançados
   - vá até dados do usuário e insira o script:
