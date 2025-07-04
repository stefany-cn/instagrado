# import psycopg2
# import os


# conn = psycopg2.connect(
#     dbname="Instagrado",
#     user=os.environ["PGUSER"],
#     password=os.environ["PGPASSWORD"],
#     host="localhost",
#     port="5432"
# )

# cur = conn.cursor()

# # Exemplo: consultando dados
# cur.execute("SELECT * FROM CRIADORES_DE_CONTEUDO;")
# usuarios = cur.fetchall()
# for usuario in usuarios:
#     print(usuario)

import psycopg2
import os
import re                   # Importa a biblioteca re para expressões regulares
from pathlib import Path    # Importa Path para manipulação de caminhos de arquivos



def carregar_consultas(caminho_consultas):
    with open(caminho_consultas, "r") as f:
        conteudo = f.read()
    
    # Expressão regular para encontrar blocos de consulta: 
    # Procura por "-- CONSULTA X" até o próximo "-- CONSULTA" ou fim do arquivo
    padrao = re.compile(r'-- CONSULTA (\d+).*?(?=(-- CONSULTA|\Z))', re.DOTALL)
    consultas = {}
    for match in padrao.finditer(conteudo):
        numero = int(match.group(1))
        texto = match.group(0)
        
        # Pega apenas o SQL (a parte após o cabeçalho)
        sql_match = re.search(r'(SELECT|WITH|INSERT|UPDATE|DELETE).*', texto, re.DOTALL | re.IGNORECASE)
        if sql_match:
            consultas[numero] = sql_match.group(0).strip().rstrip(";") + ";"  # garante que termina com ;
    return consultas

def exibir_menu(consultas):
    print("\n=== MENU DE CONSULTAS ===")
    for numero in sorted(consultas.keys()):
        print(f"{numero}. CONSULTA {numero}")
    print("0. Sair")

def executar_consulta(conn, sql):
    cur = conn.cursor()
    cur.execute(sql)
    if cur.description:  # Só faz fetch se tiver retorno (SELECT)
        resultados = cur.fetchall()
        print("\n=== RESULTADOS ===")
        for row in resultados:
            print(row)
    else:
        print("Consulta executada com sucesso (sem retorno).")
    cur.close()

def main():
    # Caminho absoluto para consultas.sql
    caminho_script = Path(__file__).resolve()
    caminho_consultas = caminho_script.parent / "../../../etapa ii/consultas.sql"

    # Carrega consultas
    consultas = carregar_consultas(caminho_consultas.resolve())

    # Conexão com o banco
    conn = psycopg2.connect(
        dbname="instagrado",
        user=os.environ["PGUSER"],
        password=os.environ["PGPASSWORD"],
        host="localhost",
        port="5432"
    )

    while True:
        exibir_menu(consultas)
        escolha = input("\nDigite o número da consulta a executar (ou 0 para sair): ")
        
        if escolha == "0":
            break
        try:
            numero = int(escolha)
            sql = consultas.get(numero)
            if sql:
                executar_consulta(conn, sql)
            else:
                print("Consulta não encontrada!")
        except ValueError:
            print("Por favor, digite um número válido!")

    conn.close()
    print("Conexão encerrada. Até mais!")

if __name__ == "__main__":
    main()
