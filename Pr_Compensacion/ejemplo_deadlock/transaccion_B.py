import psycopg2
import time

conn = psycopg2.connect(
    host="localhost",
    port="5433",
    database="PCompensacion",
    user="postgres",
    password="root"
)

conn.autocommit = False

cur = conn.cursor()

print("Bloqueando cuenta 2")

cur.execute("""
UPDATE cuentas
SET saldo = saldo - 50
WHERE id = 2
""")

time.sleep(7)

print("Intentando bloquear cuenta 1")

cur.execute("""
UPDATE cuentas
SET saldo = saldo + 50
WHERE id = 1
""")

conn.commit()

print("Transferencia completada")