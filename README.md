# Desafio de Deploy de Aplicações Python com ECS, Terraform e GitHub Actions

Este repositório contém a solução para um desafio prático que envolve a containerização de aplicações Python e o deploy em um ambiente AWS ECS (Elastic Container Service) utilizando Terraform para provisionamento da infraestrutura e GitHub Actions para CI/CD. Abaixo, você encontrará instruções sobre como utilizar o projeto e as decisões tomadas durante o desenvolvimento.

## Tarefas Práticas Resolvidas

### Containerização das Aplicações em Python
As aplicações foram containerizadas usando Docker. Foram criadas duas aplicações:

- **App**: Um webserver Flask que expõe as seguintes rotas:
  - `/` : Rota raiz que retorna uma mensagem de boas-vindas.
  - `/health` : Rota de verificação de status.
- **Redirect**: Um proxy reverso que redireciona a rota `/rota1` para `/health` da aplicação App.

### Estrutura do Projeto:

- `app.py`: Contém a lógica do webserver Flask.
- `redirect.py`: Contém a lógica do proxy reverso.
- `Dockerfile`: Define a imagem Docker para as aplicações.
- `start.sh`: Script para iniciar ambas as aplicações no mesmo container.

## Deploy no AWS ECS
As aplicações foram implantadas no AWS ECS utilizando Fargate para gerenciamento de containers sem servidor. A infraestrutura foi provisionada usando Terraform.

### Estrutura da Infraestrutura:

- **VPC**: Uma VPC com sub-redes públicas e privadas.
- **ECS Cluster**: Um cluster ECS para executar as aplicações.
- **ECR**: Um repositório ECR para armazenar as imagens Docker.
- **Task Definition**: Uma definição de tarefa para executar os containers app e redirect.
- **Service**: Um serviço ECS para garantir que as tarefas estejam sempre em execução.
- **Security Group**: Um grupo de segurança para permitir tráfego nas portas 5000 e 5001.

## CI/CD com GitHub Actions
O pipeline de CI/CD foi configurado no GitHub Actions para automatizar a construção da imagem Docker, push para o ECR e deploy no ECS.

### Fluxo do Workflow:

1. **Build da Imagem Docker**: A imagem Docker é construída a partir do Dockerfile.
2. **Push para o ECR**: A imagem é enviada para o repositório ECR criado pelo Terraform.
3. **Deploy no ECS**: O Terraform é utilizado para provisionar a infraestrutura e atualizar o serviço ECS com a nova imagem.

## Provisionamento de Infraestrutura com Terraform
A infraestrutura na AWS foi provisionada usando Terraform. O projeto inclui:

- **VPC**: Criação de uma VPC com sub-redes públicas e privadas.
- **ECS**: Configuração de um cluster ECS, task definition e service.
- **ECR**: Criação de um repositório ECR para armazenar as imagens Docker.
- **IAM**: Configuração de roles e políticas para permissões necessárias.

## Testes
Para validar o funcionamento das aplicações:

1. Acesse a rota raiz da aplicação App:
   ```bash
   curl http://<ENDEREÇO_DO_APP>:5000
   ```
   **Saída esperada:**
   ```json
   {"message": "Olá, mundo!"}
   ```

2. Verifique a rota `/health`:
   ```bash
   curl http://<ENDEREÇO_DO_APP>:5000/health
   ```
   **Saída esperada:**
   ```json
   {"status": "UP"}
   ```

3. Teste a rota `/rota1` na aplicação Redirect:
   ```bash
   curl http://<ENDEREÇO_DO_REDIRECT>:5001/rota1
   ```
   **Saída esperada:**
   ```json
   {"status": "UP"}
   ```

## Decisões Técnicas

### Containerização
- **Uso de um único container**: Para simplificar, ambas as aplicações (app e redirect) foram executadas no mesmo container usando um script de inicialização (`start.sh`). Isso reduz a complexidade de gerenciar múltiplos containers.
- **Imagem base**: Foi utilizada a imagem `python:3.9-slim` para garantir um ambiente leve e compatível com as dependências do projeto.

### AWS ECS
- **Fargate**: O uso do Fargate permite executar containers sem gerenciar servidores, reduzindo a complexidade operacional.
- **Task Definition**: Configurada para executar dois containers (app e redirect) na mesma tarefa, garantindo que ambos estejam sempre ativos.
- **Security Group**: Configurado para permitir tráfego nas portas 5000 e 5001, garantindo que as aplicações sejam acessíveis.

### Terraform
- **Modularidade**: O código Terraform foi organizado em arquivos separados para melhorar a legibilidade e manutenção.
- **State Management**: O estado do Terraform foi configurado para ser armazenado em um bucket S3, garantindo consistência e segurança.
- **IAM**: As políticas de IAM foram configuradas com o princípio do menor privilégio, garantindo que apenas as permissões necessárias sejam concedidas.

### CI/CD com GitHub Actions
- **Reusable Workflow**: O uso de workflows reutilizáveis no GitHub Actions facilita a manutenção e escalabilidade do pipeline.
- **OIDC para AWS**: A autenticação com AWS foi feita usando OIDC, eliminando a necessidade de armazenar credenciais estáticas.

## Como Utilizar Este Projeto

### Pré-requisitos

- Conta AWS com permissões para criar recursos.
- Repositório configurado com GitHub Actions e OIDC para AWS.

### Passos para Execução

```bash
git clone https://github.com/jgpjuniorj/desafio-app
cd desafio-app
git push origin main
```

O GitHub Actions irá:

1. Construir a imagem Docker.
2. Fazer push da imagem para o ECR.
3. Provisionar a infraestrutura com Terraform.
4. Fazer deploy no ECS.

Acesse as aplicações:

- **App**: `http://<ENDEREÇO_DO_APP>:5000`
- **Redirect**: `http://<ENDEREÇO_DO_REDIRECT>:5001/rota1`

