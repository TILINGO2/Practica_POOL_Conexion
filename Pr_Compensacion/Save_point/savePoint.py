import psycopg2

conn = psycopg2.connect(
    host="localhost",
    port="5433",
    database="PCompensacion",
    user="postgres",
    password="root"
)

cur = conn.cursor()

try:

    cur.execute("BEGIN")

    cur.execute("""
        INSERT INTO pedido(cliente)
        VALUES('Juan')
    """)

    cur.execute("SAVEPOINT sp_detalle")

    cur.execute("""
        INSERT INTO detalle_pedido(
            pedido_id,
            producto,
            cantidad
        )
        VALUES(2,'Laptop',2)
    """)

    # Genera error
    cur.execute("""
        INSERT INTO detalle_pedido(
            pedido_id,
            producto,
            cantidad
        )
        VALUES(999,'Mouse',2)
    """)

except Exception as e:

    print("Error:", e)

    cur.execute(
        "ROLLBACK TO SAVEPOINT sp_detalle"
    )

    cur.execute("""
        INSERT INTO detalle_pedido(
            pedido_id,
            producto,
            cantidad
        )
        VALUES(2,'Teclado',2)
    """)

    conn.commit()

finally:

    conn.close()