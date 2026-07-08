import psycopg2


def reservar_vuelo(cur, cliente):

    cur.execute("""
    INSERT INTO reservas_vuelo(cliente,estado)
    VALUES(%s,'CONFIRMADO')
    """,(cliente,))


def reservar_hotel(cur, cliente):

    raise Exception("Hotel lleno")


def cancelar_vuelo(cur, cliente):

    cur.execute("""
    UPDATE reservas_vuelo
    SET estado='CANCELADO'
    WHERE cliente=%s
    """,(cliente,))


conn = psycopg2.connect(
    host="localhost",
    port="5433",
    database="PCompensacion",
    user="postgres",
    password="root"
)

conn.autocommit = False

cur = conn.cursor()

cliente = "Juan"

try:

    print("Reservando vuelo")

    reservar_vuelo(cur, cliente)

    conn.commit()

    print("Vuelo confirmado")

    print("Reservando hotel")

    reservar_hotel(cur, cliente)

    conn.commit()

except Exception as e:

    print("Error:", e)

    print("Ejecutando compensación")

    cancelar_vuelo(cur, cliente)

    conn.commit()

finally:

    conn.close()

