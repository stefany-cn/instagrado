import psycopg2
import os


conn = psycopg2.connect(
    dbname="Instagrado",
    user=os.environ["PGUSER"],
    password=os.environ["PGPASSWORD"],
    host="localhost",
    port="5432"
)

cur = conn.cursor()

# Exemplo: consultando dados
cur.execute("SELECT * FROM CRIADORES_DE_CONTEUDO;")
usuarios = cur.fetchall()
for usuario in usuarios:
    print(usuario)