import time 
import psycopg2 
from psycopg2 import pool

# Configuración de credenciales (Ajusta estos datos a tu BD) 

DB_CONFIG = { 
    "database": "Conexion", 
    "user": "postgres", 
    "password": "05092005sC", 
    "host": "192.168.209.97", 
    "port": "5432" 
    } 



def consulta_sin_pool(): # Abre conexión física
    conexion = psycopg2.connect(**DB_CONFIG) 
    cursor = conexion.cursor() 
    # Ejecuta una consulta simple 
    cursor.execute("SELECT 1;")
    cursor.fetchone() 
    # Cierra todo 
    cursor.close() 
    conexion.close



# Inicializamos el Pool (Min: 2, Max: 10 conexiones)
print("--- Inicializando el Pool de Conexiones ---")
db_pool = pool.SimpleConnectionPool(2, 10, **DB_CONFIG)

def consulta_con_pool():
    conexion = None
    try:
        # En lugar de crear, pedimos una conexión al pool
        conexion = db_pool.getconn()
        cursor = conexion.cursor()
        cursor.execute("SELECT 1;")
        cursor.fetchone()
        cursor.close()
    except Exception as e:
        print(f"Error: {e}")
    finally:
        if conexion:
            # SÚPER IMPORTANTE: devolvemos la conexión al pool, NO la cerramos
            db_pool.putconn(conexion)

ITERACIONES = 1000

print(f"\nEjecutando {ITERACIONES} consultas SIN POOL...")
inicio_sin_pool = time.time()
for _ in range(ITERACIONES):
    consulta_sin_pool()
fin_sin_pool = time.time()
tiempo_sin_pool = fin_sin_pool - inicio_sin_pool
print(f"Tiempo total SIN POOL: {tiempo_sin_pool:.4f} segundos")

print(f"\nEjecutando {ITERACIONES} consultas CON POOL...")
inicio_con_pool = time.time()
for _ in range(ITERACIONES):
    consulta_con_pool()
fin_con_pool = time.time()
tiempo_con_pool = fin_con_pool - inicio_con_pool
print(f"Tiempo total CON POOL: {tiempo_con_pool:.4f} segundos")

# Calcular ganancia
mejora = (tiempo_sin_pool / tiempo_con_pool)
print(f"\n¡El Pool de conexiones fue aproximadamente {mejora:.1f} veces más rápido!")

# Al apagar la aplicación se cierra el pool por completo
db_pool.closeall()