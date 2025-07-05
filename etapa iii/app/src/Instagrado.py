#     		  Universidade Federal do Rio Grande do Sul
#             	           Instituto de Informática
#       	    Departamento de Informática Aplicada
#
#      	   INF01145 Fundamentos de Banco de Dados
#                   Profa. Dra. Karin Becker # Turma A
#
#           		 TRABALHO DA DISCIPLINA
#
#    Eduardo Veiga Ferreira (578144) e Stefany Costa Nascimento (263870)

# ===========================================================================================================================================
# BIBLIOTECAS E IMPORTAÇÕES
# ===========================================================================================================================================

import psycopg2
import os
import re                   # Importa a biblioteca re para expressões regulares
from pathlib import Path    # Importa Path para manipulação de caminhos de arquivos

# ===========================================================================================================================================
# FUNCOES PARA CONSULTAS E COMANDO NO BANCO DE DADOS 
# ===========================================================================================================================================
def usuarios_comentados(conn,usuario):
    """
    Encontra contas em que um dado usuario comentou.
    """
    # A consulta SQL com o placeholder %s
    sql_query = """    
        SELECT c.nome_usuario
        FROM CONTAS c
        WHERE EXISTS (SELECT * 
                    FROM PUBLICACOES p 
                    WHERE p.id_conta = c.id_conta 
        AND EXISTS (SELECT * 
                    FROM COMENTARIOS co JOIN CONTAS c2 ON co.id_conta = c2.id_conta 
                    WHERE co.id_publicacao = p.id_publicacao AND c2.nome_usuario = %s));
    """
    
    resultados = []
    try:    
        cur = conn.cursor()
        
        # Executa a consulta passando o valor como um segundo argumento.
        # Note que passamos como uma tupla: (usuario,)
        # A vírgula é necessária para que o Python entenda que é uma tupla de um elemento.
        cur.execute(sql_query, (usuario,))
                
        # Busca os resultados
        resultados = cur.fetchall()
        
        cur.close()
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally:
        if(resultados):
            print(f"Usuários que {usuario} comentou na publicação:")
            for row in resultados:
                print(row[0])

    return resultados

def perfil(conn, usuario):

    """
    Encontra contas em que um dado usuario comentou.
    """
    # A consulta SQL com o placeholder %s
    sql_query = """    
        SELECT nome_usuario, data_publicacao, P.descricao, conteudo
        FROM CONTAS_PERFIS CP JOIN PUBLICACOES P ON ( CP.id_conta = P.id_conta) NATURAL JOIN MIDIAS
        WHERE nome_usuario = %s
        ORDER BY nome_usuario;
    """
    
    resultados = []
    try:    
        cur = conn.cursor()
        
        # Executa a consulta passando o valor como um segundo argumento.
        # Note que passamos como uma tupla: (usuario,)
        # A vírgula é necessária para que o Python entenda que é uma tupla de um elemento.
        cur.execute(sql_query, (usuario,))
            
        # Busca os resultados
        resultados = cur.fetchall()
        
        cur.close()
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally:
        if(resultados):
            print(f"--- Perfil de '{usuario}' ---")
            for row in resultados:
                print(f"Descrição: {row[2]} \nConteduo de midia: {row[3]} \n{row[1]} \n")

    return resultados

def insert_visualizacao(conn, usuario_criador, usuario_perfil):
    """
    Insere uma visualização de perfil no banco de dados.
    """
    try:
        cur = conn.cursor()
        
        # Consulta para inserir a visualização
        sql_insert = """
            INSERT INTO VISUALIZACOES (id_criador, id_perfil)
            SELECT CC.id_criador, CP.id_perfil
            FROM CONTAS_CRIADORES CC, CONTAS_PERFIS CP
            WHERE CC.nome_usuario = %s AND CP.nome_usuario = %s;
        """
        
        # Executa a inserção
        cur.execute(sql_insert, (usuario_criador, usuario_perfil))
        
        # Confirma a transação
        conn.commit()
        
        print(f"Visualização registrada: {usuario_criador} visualizou o perfil de {usuario_perfil}.")
        
        cur.close()
    except (Exception, psycopg2.DatabaseError) as error:
        print(f"Erro ao registrar visualização: {error}")

def visualizadores(conn,usuario):
    """
    Encontra contas em que um dado usuario comentou.
    """
    # A consulta SQL com o placeholder %s
    sql_query = """    
        SELECT CC.nome_usuario Criador, CP.nome_usuario Visualizadores, visualizacoes_do_perfil
        FROM CRIADORES_DE_CONTEUDO CDC 
            JOIN CONTAS_CRIADORES CC ON (CDC.id_criador = CC.id_criador)
	        JOIN VISUALIZACOES V ON (CDC.id_criador = V.id_criador)
	        JOIN CONTAS_PERFIS CP ON (V.id_perfil = CP.id_perfil)
        WHERE CC.nome_usuario = %s;
    """
    
    resultados = []
    try:    
        cur = conn.cursor()
        
        # Executa a consulta passando o valor como um segundo argumento.
        # Note que passamos como uma tupla: (usuario),)
        # A vírgula é necessária para que o Python entenda que é uma tupla de um elemento.
        cur.execute(sql_query, (usuario,))
                
        # Busca os resultados
        resultados = cur.fetchall()
        
        cur.close()
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally:
        if(resultados):
            print(f"--Visualizacoes Total: {resultados[0][2]}--")
            for row in resultados:
                print(row[1])

    return resultados

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


''' ======= Exibe o menu de consultas disponíveis ======= '''

def exibir_menu(consultas):
    print("\n=== MENU DE CONSULTAS ===")
    for numero in sorted(consultas.keys()):
        print(f"{numero}. CONSULTA {numero}")
    print("0. Sair")

def executar_comando(conn, sql):
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

# ===========================================================================================================================================
# MAIN
# ===========================================================================================================================================
def main():
    # Caminho absoluto para consultas.sql
    caminho_script = Path(__file__).resolve()
    caminho_consultas = caminho_script.parent / "../../../etapa ii/consultas.sql"

    # Carrega consultas
    consultas = carregar_consultas(caminho_consultas.resolve())

    # Conexão com o banco
    conn = psycopg2.connect(
        dbname="Instagrado",
        user=os.environ["PGUSER"],
        password=os.environ["PGPASSWORD"],
        host="localhost",
        port="5432"
    )

    print("\n=== Bem-vindo ao Instagrado! ===")
    usuario1 = input("Digite seu nome de usuario: ")
    if not usuario1.strip():
        print("Nome de usuário não pode ser vazio. Tente novamente.")


    print(f"\nOla, {usuario1}! Veja as ultimas contas que visualizaram seu perfil:")
    visualizadores(conn, usuario1.strip())

    print("\nVeja as contas que você mais interage!\n")
    usuarios_comentados(conn, usuario1.strip())

    usuario2 = input("\nBusque um perfil por nome de usuario: ")
    if not usuario2.strip():
        print("Nome de usuário não pode ser vazio. Tente novamente.")
    else: 
        perfil(conn, usuario2.strip())
        insert_visualizacao(conn, usuario1.strip(), usuario2.strip())
        
    print("\n--- Teste as consultas disponiveis para esta base de dados: ---")
    escolha = -1
    while escolha != "0":

        exibir_menu(consultas)
        escolha = input("\nDigite o número da consulta a executar (ou 0 para sair): ")
        
        if escolha == "0":
            break
        try:
            numero = int(escolha)
            sql = consultas.get(numero)
            if sql:
                executar_comando(conn, sql)
            else:
                print("Consulta não encontrada!")
        except ValueError:
            print("Por favor, digite um número válido!")

    conn.close()
    print("Conexão encerrada. Até mais!")

if __name__ == "__main__":
    main()
