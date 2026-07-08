import psycopg2
import time

MAX_RETRY = 3

for intento in range(MAX_RETRY):

    try:

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

        time.sleep(5)

        print("Intentando bloquear cuenta 2")

        cur.execute("""
        UPDATE cuentas
        SET saldo = saldo + 100
        WHERE id = 2
        """)

        conn.commit()

        print("Transacción exitosa")

        break

    except psycopg2.Error as e:

        print("Error:", e)

        espera = 2 ** intento

        print(f"Reintentando en {espera} segundos")

        time.sleep(espera)

    finally:

        if 'conn' in locals():
            conn.close()