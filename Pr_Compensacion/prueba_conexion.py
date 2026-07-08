import psycopg2
import traceback

try:

    conn = psycopg2.connect(
        host="localhost",
        port="5433",
        database="PCompensacion",
        user="postgres",
        password="root"
    )

    print("Conectado")

except Exception as e:

    traceback.print_exc()