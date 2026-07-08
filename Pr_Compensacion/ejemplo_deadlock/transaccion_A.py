
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

print("Bloqueando cuenta 1")

cur.execute("""
UPDATE cuentas
SET saldo = saldo - 100
WHERE id = 1
""")

time.sleep(7)

print("Intentando bloquear cuenta 2")

cur.execute("""
UPDATE cuentas
SET saldo = saldo + 100
WHERE id = 2
""")

conn.commit()

print("Transferencia completada")