# Pr_Compensación — Transacciones, Deadlocks y Compensación en PostgreSQL

Proyecto de ejemplos en **Python + PostgreSQL** que demuestra técnicas de
**tolerancia a fallos** en operaciones de base de datos: cómo se produce un
_deadlock_, cómo manejar _timeouts_, cómo aplicar **reintentos con backoff
exponencial** y cómo implementar el patrón **Saga** con transacciones de
compensación.

## Conceptos demostrados

| Ejemplo                                 | Concepto                             | Qué muestra                                                                                                                             |
| --------------------------------------- | ------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------- |
| `ejemplo_deadlock/`                     | **Deadlock** (interbloqueo)          | Dos transacciones que bloquean recursos en orden inverso y quedan atascadas; PostgreSQL detecta el deadlock y aborta una.               |
| `ejemplo_deadlock/transaccion_retry.py` | **Reintentos + backoff exponencial** | Ante un error de bloqueo, reintenta la operación esperando cada vez más (1s, 2s, 4s…).                                                  |
| `ejemplo_timeout/`                      | **Timeout + reintentos**             | Simula un servicio lento; si tarda demasiado lanza `TimeoutError` y reintenta con backoff.                                              |
| `ejemplo_compensacion/saga.py`          | **Patrón Saga / Compensación**       | Reserva un vuelo, falla al reservar el hotel y ejecuta una acción compensatoria que cancela el vuelo para dejar el sistema consistente. |

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

| Parámetro | Valor           |
| --------- | --------------- |
| host      | `localhost`     |
| port      | `5433`          |
| database  | `PCompensacion` |
| user      | `postgres`      |
| password  | `root`          |

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

O desde pgAdmin: clic derecho sobre la base `PCompensacion` → _Query Tool_ →
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
un error tipo _deadlock detected_.

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
fallidos, informa un _fallo definitivo_. No usa base de datos.

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

## Preguntas de reflexión

1. ¿Por qué es importante usar savepoints en transacciones largas? ¿Qué problema resuelven?

   Los savepoints permiten dividir una transacción grande en partes más pequeñas y recuperar el estado hasta un punto específico sin deshacer toda la operación. Esto es muy útil cuando una transacción realiza varios pasos y uno de ellos falla. En lugar de abortar la transacción completa y perder trabajo ya realizado, se puede volver al savepoint anterior y seguir con otra estrategia. El problema principal que resuelven es evitar la pérdida innecesaria de cambios y mejorar la tolerancia a fallos en operaciones largas.

2. En el escenario de reserva, ¿qué pasaría si no usáramos savepoints y el hotel no tuviera cupo? ¿Cómo afectaría a la consistencia de los datos?

   Si no se usan savepoints y la reserva del hotel falla, la transacción completa tendría que revertirse. Sin una estrategia de compensación, podríamos terminar con una reserva de vuelo confirmada y una reserva de hotel no realizada, lo que generaría una inconsistencia entre los servicios o las tablas. En sistemas distribuidos, esto puede dejar el estado del negocio a medias. Por eso, en este tipo de escenarios es importante usar compensación o una lógica que revierta los pasos ya ejecutados.

3. ¿Cómo se produce un deadlock en una base de datos? Explica el ejemplo que implementaste y cómo lo resolviste.

   Un deadlock ocurre cuando dos o más transacciones bloquean recursos y luego intentan acceder a recursos que ya están bloqueados por otra transacción, formando un ciclo de espera. En el ejemplo implementado, la transacción A bloquea la cuenta 1 y luego intenta acceder a la cuenta 2, mientras la transacción B hace lo contrario: bloquea la cuenta 2 y luego intenta acceder a la cuenta 1. Cada una espera a la otra, y PostgreSQL detecta el ciclo y aborta una de las transacciones para romper el interbloqueo. La solución implementada fue reintentar la operación con backoff exponencial, de modo que una de las transacciones tenga oportunidad de completarse cuando el recurso ya no esté bloqueado.

4. ¿Qué estrategias de mitigación existen para evitar deadlocks en sistemas concurrentes?

   Algunas estrategias comunes son: usar un orden consistente de bloqueo de recursos, mantener las transacciones lo más cortas posible, reducir el tiempo de permanencia de los locks, evitar operaciones de usuario dentro de la transacción, usar índices adecuados para acelerar la búsqueda de filas y, cuando sea posible, implementar reintentos controlados tras detectar un deadlock. También es útil definir tiempos de espera razonables y diseñar la lógica de negocio para que no compita innecesariamente por los mismos recursos.

5. ¿Qué sucede cuando una transacción alcanza el timeout? ¿Cómo afecta al usuario final y qué mecanismos se pueden implementar para manejar esta situación?

   Cuando una transacción alcanza el timeout, la operación se considera fallida porque no pudo completarse dentro del tiempo permitido. Esto suele terminar en un rollback o en una cancelación de la operación, y el usuario final puede recibir un mensaje de error o de que el servicio no respondió a tiempo. Para manejar esta situación, se pueden implementar reintentos con backoff, mecanismos de cola, tiempos de espera configurables, respuestas amigables en la interfaz y, en operaciones distribuidas, estrategias de compensación para restaurar el estado anterior si una parte ya se ejecutó.

6. ¿Qué son las transacciones anidadas y los savepoints?

   Las transacciones anidadas, en la práctica, no son exactamente transacciones dentro de otras transacciones como en algunos lenguajes de programación, porque en bases de datos tradicionales no se permiten de forma real. Lo que sí se suele implementar es una estructura lógica de suboperaciones dentro de una misma transacción, y para controlar eso se usan los savepoints. Un savepoint marca un punto de control dentro de una transacción. Si después ocurre un error, se puede hacer rollback solo hasta ese punto, sin perder todo lo que se había hecho antes. Esto permite recuperar parcialmente una operación compleja y mantener la consistencia del sistema.

7. ¿Qué son los deadlocks y cómo se producen?

   Un deadlock es un estado de bloqueo mutuo en el que dos o más transacciones esperan recursos que están siendo retenidos por otras transacciones del mismo grupo. Se produce cuando cada una posee un recurso que la otra necesita, formando un ciclo de espera. Por ejemplo, una transacción bloquea una fila o tabla y espera otra, mientras otra hace lo mismo en sentido contrario. La base de datos detecta este ciclo y, para evitar quedar indefinidamente bloqueada, aborta una de las transacciones.

8. ¿Qué son los timeouts y cómo afectan a las transacciones?

   Un timeout es un límite de tiempo máximo que se asigna a una operación para que termine. Si la transacción no concluye dentro de ese tiempo, se considera fallida y se aborta o se cancela. En sistemas reales, esto afecta la experiencia del usuario porque puede recibir una respuesta tardía o un error de operación no completada. Para manejarlo, se suelen usar reintentos, tiempos de espera configurables y mecanismos de compensación para dejar el sistema en un estado consistente.
