# Laboratorio de Pool de Conexiones en PostgreSQL

## Descripción

Este proyecto tiene como objetivo demostrar la diferencia de rendimiento entre realizar consultas a una base de datos PostgreSQL utilizando:

- Conexiones tradicionales (abriendo y cerrando una conexión en cada consulta).
- Un Pool de Conexiones (reutilizando conexiones ya abiertas).

La prueba ejecuta múltiples consultas simples (`SELECT 1`) y mide el tiempo total empleado en ambos escenarios para comparar la eficiencia de cada enfoque.

---

## Tecnologías Utilizadas

- Python 3
- PostgreSQL
- psycopg2
- psycopg2.pool

---

## Estructura del Proyecto

```
Actividades2Parcial/
│
├── laboratorio_pool.py
├── requirements.txt
```

---

## Requisitos

### Instalar dependencias

```bash
pip install -r requirements.txt
```

O directamente:

```bash
pip install psycopg2-binary
```

---

## Configuración de la Base de Datos

Antes de ejecutar el programa, se deben ajustar las credenciales dentro del archivo:

```python
DB_CONFIG = {
    "database": "Conexion",
    "user": "postgres",
    "password": "********",
    "host": "192.168.209.97",
    "port": "5432"
}
```

Asegúrese de que:

- PostgreSQL esté en ejecución.
- La base de datos exista.
- El servidor permita conexiones desde la máquina cliente.
- Las credenciales sean correctas.

---

## Funcionamiento

### Escenario 1: Sin Pool de Conexiones

Por cada consulta:

1. Se crea una conexión física nueva.
2. Se ejecuta la consulta.
3. Se cierra la conexión.

```python
conexion = psycopg2.connect(**DB_CONFIG)
```

Este proceso se repite 1000 veces.

---

### Escenario 2: Con Pool de Conexiones

Se crea un pool de conexiones al inicio:

```python
db_pool = pool.SimpleConnectionPool(2, 10, **DB_CONFIG)
```

Donde:

- Mínimo de conexiones: 2
- Máximo de conexiones: 10

Para cada consulta:

1. Se solicita una conexión disponible al pool.
2. Se ejecuta la consulta.
3. La conexión se devuelve al pool para reutilizarse.

```python
conexion = db_pool.getconn()
```

```python
db_pool.putconn(conexion)
```

---

## Prueba Realizada

El programa ejecuta:

```python
ITERACIONES = 1000
```

consultas en cada escenario.

Consulta utilizada:

```sql
SELECT 1;
```

Esta consulta es extremadamente ligera y se utiliza únicamente para medir el costo de apertura y reutilización de conexiones.

---

## Resultados Esperados

Al finalizar la ejecución se muestran:

- Tiempo total sin pool.
- Tiempo total con pool.
- Factor de mejora obtenido.

Ejemplo:

```text
Ejecutando 1000 consultas SIN POOL...
Tiempo total SIN POOL: 15.4832 segundos

Ejecutando 1000 consultas CON POOL...
Tiempo total CON POOL: 2.1647 segundos

¡El Pool de conexiones fue aproximadamente 7.2 veces más rápido!
```

---

## Beneficios del Pool de Conexiones

- Reduce la sobrecarga de crear conexiones repetidamente.
- Mejora el rendimiento de aplicaciones con alta concurrencia.
- Disminuye el consumo de recursos del servidor.
- Permite reutilizar conexiones ya establecidas.

---
