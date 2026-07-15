# Pr_Compensación — Transacciones, Deadlocks y Compensación en PostgreSQL

Proyecto de ejemplos en **Python + PostgreSQL** que demuestra técnicas de
**tolerancia a fallos** en operaciones de base de datos: cómo se produce un
*deadlock*, cómo manejar *timeouts*, cómo aplicar **reintentos con backoff
exponencial** y cómo implementar el patrón **Saga** con transacciones de
compensación.

## Conceptos demostrados

| Ejemplo | Concepto | Qué muestra |
|---|---|---|
| `ejemplo_deadlock/` | **Deadlock** (interbloqueo) | Dos transacciones que bloquean recursos en orden inverso y quedan atascadas; PostgreSQL detecta el deadlock y aborta una. |
| `ejemplo_deadlock/transaccion_retry.py` | **Reintentos + backoff exponencial** | Ante un error de bloqueo, reintenta la operación esperando cada vez más (1s, 2s, 4s…). |
| `ejemplo_timeout/` | **Timeout + reintentos** | Simula un servicio lento; si tarda demasiado lanza `TimeoutError` y reintenta con backoff. |
| `ejemplo_compensacion/saga.py` | **Patrón Saga / Compensación** | Reserva un vuelo, falla al reservar el hotel y ejecuta una acción compensatoria que cancela el vuelo para dejar el sistema consistente. |

## Requisitos

- **Python 3.8+**
- **PostgreSQL** en ejecución
- Librería **psycopg2**:
  ```bash
  pip install psycopg2-binary
  ```

## Estructura del proyecto

```
Pr_Compensacion/
├── prueba_conexion.py            # Verifica la conexión a la base de datos
├── ejemplo_deadlock/
│   ├── transaccion_A.py          # Bloquea cuenta 1, luego intenta la 2
│   ├── transaccion_B.py          # Bloquea cuenta 2, luego intenta la 1  → deadlock
│   └── transaccion_retry.py      # Misma operación con reintentos y backoff
├── ejemplo_timeout/
│   └── timeout_retry.py          # Servicio simulado con timeout y reintentos
└── ejemplo_compensacion/
    └── saga.py                   # Reserva vuelo/hotel con compensación
```

## Configuración de la base de datos

Todos los scripts se conectan con estos parámetros (definidos dentro de cada
archivo `.py`):

| Parámetro | Valor |
|---|---|
| host | `localhost` |
| port | `5433` |
| database | `PCompensacion` |
| user | `postgres` |
| password | `root` |

> Si tu PostgreSQL usa otro puerto, usuario o contraseña, ajústalo en cada
> script (o mejor, en un solo lugar si centralizas la conexión).

### 1. Crear la base de datos

En `psql` o pgAdmin:

```sql
CREATE DATABASE "PCompensacion";
```

### 2. Restaurar el backup (estructura de tablas)

El archivo **`ScriptBD.sql`** es un volcado (`pg_dump`) con la estructura de las
tablas: `cuentas`, `reservas_hotel`, `reservas_vuelo`, `pedido` y
`detalle_pedido`.

Desde la terminal:

```bash
psql -h localhost -p 5433 -U postgres -d PCompensacion -f ScriptBD.sql
```

O desde pgAdmin: clic derecho sobre la base `PCompensacion` → *Query Tool* →
abrir y ejecutar `ScriptBD.sql`.

### 3. Cargar datos de ejemplo (necesario para el deadlock)

El backup solo crea las tablas **vacías**. El ejemplo de deadlock necesita que
existan las cuentas con `id = 1` y `id = 2`, así que inserta datos de prueba:

```sql
INSERT INTO cuentas (propietario, saldo) VALUES
    ('Ana',  1000.00),
    ('Luis', 1000.00);
```

## Cómo ejecutar cada ejemplo

### Prueba de conexión

Confirma que Python puede conectarse antes de correr los demás ejemplos:

```bash
python prueba_conexion.py
```

Debe imprimir `Conectado`. Si falla, revisa que PostgreSQL esté encendido y que
el puerto/credenciales coincidan.

### Deadlock

Este ejemplo requiere **dos terminales abiertas al mismo tiempo**, porque el
interbloqueo solo ocurre cuando dos transacciones compiten en paralelo:

```bash
# Terminal 1
python ejemplo_deadlock/transaccion_A.py

# Terminal 2 (arráncala en los ~7 segundos siguientes)
python ejemplo_deadlock/transaccion_B.py
```

`transaccion_A` bloquea la cuenta 1 y espera; `transaccion_B` bloquea la cuenta
2 y espera. Cuando cada una intenta bloquear la cuenta que la otra ya tiene, se
forma el deadlock. PostgreSQL lo detecta y aborta una de las transacciones con
un error tipo *deadlock detected*.

### Deadlock con reintentos

```bash
python ejemplo_deadlock/transaccion_retry.py
```

Ejecuta la misma transferencia, pero si ocurre un error de bloqueo reintenta
hasta 3 veces, esperando `2^intento` segundos entre cada intento (backoff
exponencial: 1s, 2s, 4s).

### Timeout con reintentos

```bash
python ejemplo_timeout/timeout_retry.py
```

Simula un servicio de reservas cuyo tiempo de respuesta es aleatorio (1–8 s). Si
supera los 5 s lanza `TimeoutError` y reintenta con backoff. Tras 3 intentos
fallidos, informa un *fallo definitivo*. No usa base de datos.

### Saga / Compensación

```bash
python ejemplo_compensacion/saga.py
```

Flujo del ejemplo:
1. Reserva un vuelo para el cliente y hace `commit` → estado `CONFIRMADO`.
2. Intenta reservar el hotel, que **falla a propósito** ("Hotel lleno").
3. Al fallar, ejecuta la **compensación**: actualiza el vuelo a `CANCELADO`.

Así el sistema queda consistente aunque una parte de la operación distribuida
haya fallado. Puedes verificar el resultado con:

```sql
SELECT * FROM reservas_vuelo;
```

## Notas

- El puerto **5433** no es el predeterminado de PostgreSQL (5432). Verifica cuál
  usa tu instalación y ajústalo si es necesario.
- Los ejemplos usan `autocommit = False` para controlar manualmente cuándo se
  confirma (`commit`) o se revierte cada transacción, que es la base para
  observar bloqueos y compensaciones.
- Para reejecutar los ejemplos desde cero, puedes limpiar las tablas:
  ```sql
  TRUNCATE reservas_vuelo, reservas_hotel RESTART IDENTITY;
  UPDATE cuentas SET saldo = 1000.00;
  ```
