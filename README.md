# Instagrado - Guia de Configuração

Este projeto utiliza **Python** para acessar um banco de dados **PostgreSQL** (SGBD).  
Abaixo estão os passos para configurar o ambiente e executar o código com segurança.

---

## 1. Pré-requisitos

- Python 3 instalado
- PostgreSQL instalado e rodando
- Acesso ao banco de dados chamado `Instagrado`

---

## 2. Criando um Ambiente Virtual

No terminal, dentro da pasta do projeto, execute:

```bash
python3 -m venv venv
```

Ative o ambiente virtual:

```bash
source venv/bin/activate
```

---

## 3. Instalando as Dependências

Com o ambiente virtual ativado, instale o driver do PostgreSQL:

```bash
pip install psycopg2-binary
```

---

## 4. Configurando as Variáveis de Ambiente

Para manter sua senha segura, use variáveis de ambiente.  
No terminal, defina as variáveis antes de rodar o script:

```bash
export PGUSER=seu_usuario
export PGPASSWORD=sua_senha
```

Substitua `seu_usuario` e `sua_senha` pelos dados do seu PostgreSQL.

---

## 5. Executando o Código

Com o ambiente virtual ativado e as variáveis de ambiente configuradas, execute:

```bash
python etapa\ iii/app/src/Instagrado.py
```

---

## 6. Observações

- O código conecta ao banco de dados `Instagrado` na máquina local (`localhost`) usando a porta padrão `5432`.
- O acesso ao banco é feito de forma segura, sem expor a senha no código.
- Para listar os usuários do PostgreSQL, use:
  ```bash
  sudo -u postgres psql -c "\du"
  ```
- Se precisar redefinir a senha de um usuário PostgreSQL:
  ```bash
  sudo -u postgres psql
  \password nome_do_usuario
  ```

---
