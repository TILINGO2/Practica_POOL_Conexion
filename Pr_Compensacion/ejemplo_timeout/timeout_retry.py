import random
import time
import time

def reservar_hotel():

    tiempo = random.randint(1,8)

    print("Tiempo respuesta:", tiempo)

    time.sleep(tiempo)

    if tiempo > 2:
        raise TimeoutError("Timeout")

    return True



for intento in range(3):

    try:

        reservar_hotel()

        print("Reserva exitosa")

        break

    except TimeoutError:

        print("Timeout")

        espera = 2 ** intento

        print(f"Reintentando en {espera} segundos")

        time.sleep(espera)

else:

    print("Fallo definitivo")