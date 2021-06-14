/* Fuentes, Tiffany - Renison, Iván - Organización del computador - FaMAF */

.ifndef logica_s
.equ logica_s, 0

.include "datos.s" 


/* nuevoNumeroAleatorio:
    Parámetro:
        x1 = Número de entrada

    Crea un número aleatorio a partir del valor en x1, y lo guarda en x1.
    A partir de la misma entrada se obtiene la misma salida, pero a cualquier pequeño cambio en la
    entrada, la salida cambia completamente.

    Utiliza x9.
    Modifica x1.
 */
/* Detalles del funcionamiento: https://en.wikipedia.org/wiki/Linear-feedback_shift_register */
nuevoNumeroAleatorio:
    cmp x1, #0
    csinc x1, x1, xzr, ne // x1 = x1 != 0 ? x1 : x1 + 1   // Si x1 = 0 el algoritmo da siempre en 0, así que en ese caso lo cambio a 1
    eor x9, x1, x1, lsr #2
    eor x9, x9, x1, lsr #3
    eor x9, x9, x1, lsr #5
    lsl x9, x9, #15
    orr x1, x9, x1, lsr #1
    
    br lr // return
//

/* numeroAleatorio:
    Pone un número aleatorio (según semilla) en x1.

    Utiliza x9.
 */
/* Detalles del funcionamiento:
    Utiliza nuevoNumeroAleatorio para obtener un un nuevo aleatorio, el cuál lo devuelve, y lo guarda en semilla.
 */
numeroAleatorio:
    sub sp, sp, #8 // Guardo el puntero de retorno en el stack
    stur lr, [sp]

    ldr x1, semilla // Pongo en x1 la semilla actual
    bl nuevoNumeroAleatorio // Pongo en x1 un nuevo número aleatorio
    adr x9, semilla
    str x1, [x9] // Actualizo la semilla

    ldur lr, [sp] // Recupero el puntero de retorno del stack
    add sp, sp, #8 
    br lr // return
//


/* generarAlturaNuevoTubo:
    Parámetros:
        x1 = Altura tubo anterior

    Devuelve en x1 la altura para el nuevo tubo.
    La máxima diferencia entre el tubo anterior y el nuevo es de 2^difAlturasTubos.
    Lo mas cerca de un borde que permite que esté es tamanioHuecoTubo/2.

    Utiliza x9 y x10.
    Modifica x1.
 */
/* Detalles del funcionamiento:
    Obtiene un numero aleatorio de difAlturasTubos + 1 bits, osea, que va de
    2^difAlturasTubos - 1 a 2^difAlturasTubos + 1, luego le suma ese número a la altura del tubo anterior, 
    si se pasa del margen vuelve a generar un número aleatorio y a hacer todo de vuelta.
 */
generarAlturaNuevoTubo:
        sub sp, sp, #8 // Guardo el puntero de retorno en el stack
        stur lr, [sp]

        mov x10, x1 // Guardo la altura del tubo anterior en x10

    restart_generarAlturaNuevoTubo: // Para reiniciar la generación de la altura si se pasa de un extremo
        mov x1, x10

        bl numeroAleatorio
        .equ difAlturasTubos_, 62 - difAlturasTubos // difAlturasTubos_ = la cantidad de bits que tienen que correrse
        asr x1, x1, difAlturasTubos_
        add x1, x10, x1 // x1 = altura tubo anterior + número aleatorio

        // Verifico que no se pase del mínimo
        mov x9, tamanioHuecoTubo
        cmp x1, tamanioHuecoTubo
        b.lt restart_generarAlturaNuevoTubo // Si se pasa del mínimo re-empieza

        // Verifico que no se pase del máximo
        .equ margenInfarior, alturaPiso - tamanioHuecoTubo
        mov x9, margenInfarior
        cmp x1, x9
        b.gt restart_generarAlturaNuevoTubo // Si se pasa del máximo re-empieza

        ldur lr, [sp] // Recupero el puntero de retorno del stack
        add sp, sp, #8 
        br lr // return
//

/* inicializarTubos:
    Inicializa la altura de los tubos.
    Pone en el primero alturaTuboInicial, y en el resto va cambiando la altura aleatoriamente (según semilla).

    Modifica el arreglo alturaTubos.

    Utiliza x1, x2, x9, x10, x11 y x12.
 */
inicializarTubos:
        sub sp, sp, #8 // Guardo el puntero de retorno en el stack
        stur lr, [sp]

        adr x11, alturaTubos
        mov x1, alturaTuboInicial
        stur x1, [x11] // Inicializo el primer tubo
        mov x12, #1
    loop_inicializarTubos: // Inicializo el resto de los tubos
        cmp x12, cantidadDeTubos
        b.hs end_loop_inicializarTubos

        bl generarAlturaNuevoTubo
        str x1, [x11, x12, lsl #3] // Inicializo el elemento x12
        add x12, x12, #1

        b loop_inicializarTubos
    end_loop_inicializarTubos:

        ldur lr, [sp] // Recupero el puntero de retorno del stack
        add sp, sp, #8 
        br lr // return
//


/* moverTubos:
    No tiene parámetros.

    Muevo los tubos guardados en memoría en velocidadTubos a la izquierda, y si un tubo ya se sale de
    la pantalla, agrega uno nuevo a la derecha.

    Utiliza x9, x10 y x11.
 */
moverTubos:
        sub sp, sp, #8 // Guardo el puntero de retorno en el stack
        stur lr, [sp]

        ldr x10, posicionEnXPrimerTubo
        sub x10, x10, velocidadTubos // x10 = nueva posición en x del primer tubo
        adr x11, posicionEnXPrimerTubo
        stur x10, [x11]
        .equ neg_anchoTubo, -anchoTubo
        cmp x10, neg_anchoTubo // Si la posición del tubo es menor a -ancho tubo, ya no se ve, y por ende lo saco
        b.ge end_moverTubos
    // Elimino un tubo y agrego uno a la derecha

        // Actualizo la distancia al primer tubo
        ldr x9, posicionEnXPrimerTubo
        add x9, x9, distanciaEntreTubos // Hago que la distancia al primer tubo sea la distancia que había al que era el segundo tubo
        adr x10, posicionEnXPrimerTubo
        stur x9, [x10] // Pongo en posicionEnXPrimerTubo la distancia que antes había hasta el segundo tubo

        // Obtengo la altura del tubo que se va a agregar
        adr x9, alturaTubos // x9 = dirección de memoria de alturaTubos
        .equ indice_ultimoTubo, 8*(cantidadDeTubos - 1)
        ldr x1, [x9, indice_ultimoTubo]
        bl generarAlturaNuevoTubo // Pongo en x1 la altura que va a tener el próximo tubo

    // Muevo una posición para adelante todos los elementos del arreglo alturaTubos
        adr x9, alturaTubos // x9 = dirección de memoria de alturaTubos
        mov x10, cantidadDeTubos
    loop_moverTubos:
        subs x10, x10, #1
        b.lt end_moverTubos
        ldr x11, [x9, x10, lsl #3] // Guardo temporalmente el elemento de la posición x10 en x11
        str x1, [x9, x10, lsl #3]  // Guardo la altura de la iteración anterior en la posición x10 en x11
        mov x1, x11 // Pongo en x1 el elemento de la posición x10, para la siguiente iteración
        b loop_moverTubos

    end_moverTubos:
        ldur lr, [sp] // Recupero el puntero de retorno del stack
        add sp, sp, #8 
        br lr // return
//


/* actualizarAlturaFlappy:
    No tiene parámetros.

    Actualiza en memoria:
    alturaFlappy = alturaFlappy + velocidadFlappy

    Utiliza x9 y x10.
 */
actualizarAlturaFlappy:
    ldr x9, alturaFlappy
    ldr x10, velocidadFlappy
    add x9, x9, x10
    adr x10, alturaFlappy
    str x9, [x10]

    br lr // return
//


/* obtenerAlturaSiguienteTubo:
    No tiene parámetros.

    Devuelve en x1 la altura de la parte de arriba del tubo de abajo del primer tubo que está a la derecha del flappy.
    Usar para decidir si hacer un salto o no.

    No utiliza ningún registro extra.
 */
/* Detalles del funcionamiento:
    Básicamente calcula:
        ( posicionEnXPrimerTubo >= offSetEnXFlappy - radioFlappy - anchoTubo
            ? alturaTubos[0]
            : alturaTubos[1]
        ) + tamanioHuecoTubo/2
 */
obtenerAlturaSiguienteTubo:
        .equ offSetEnXFlappy_menos_radioFlappy_menos_anchoTubo_div_2, (offSetEnXFlappy - radioFlappy - anchoTubo/2)
        ldr x1, posicionEnXPrimerTubo
        cmp x1, offSetEnXFlappy_menos_radioFlappy_menos_anchoTubo_div_2
        b.ge else_obtenerAlturaSiguienteTubo

        // Caso el siguiente tubo es el segundo tubo
        adr x1, alturaTubos
        ldr x1, [x1, #8]
        b fi_obtenerAlturaSiguienteTubo

    else_obtenerAlturaSiguienteTubo:
        // Caso el siguiente tubo es el primer tubo
        ldr x1, alturaTubos

    fi_obtenerAlturaSiguienteTubo:

        .equ tamanioHuecoTubo_div_2, tamanioHuecoTubo/2
        add x1, x1, tamanioHuecoTubo_div_2 // Como lo que obtuve es la altura del centro del tubo, le sumo la mitad del tamaño del hueco

        br lr // return
//

/* actualizarVelocidadFlappy:
    No tiene parámetros.

    Si el flappy tiene que saltar, pone la velocidad en capacidadSaltoFlappy, si no le suma la gravedad.
    Decide si tiene que saltar si en el proximo fotograma va a quedar mas abajo que la altura de la
    base del siguiente tubo.

    Utiliza x1, x9, x10.
 */
/* Detalles del funcionamiento:

    Actualiza en memoria:
    velocidadFlappy = alturaFlappy + radioFlappy <= AlturaSiguienteTubo - tamanioHuecoTubo/4
                          ? velocidadFlappy + gravedad
                          : capacidadSaltoFlappy
 */
actualizarVelocidadFlappy:
        sub sp, sp, #8 // Guardo el puntero de retorno en el stack
        stur lr, [sp]

        bl obtenerAlturaSiguienteTubo // x1 = AlturaSiguienteTubo

        ldr x10, alturaFlappy
        add x10, x10, radioFlappy // x10 = altura parte de abajo flappy
        ldr x9, velocidadFlappy
        add x9, x9, gravedad
        add x10, x10, x9 // x10 = altura parte de abajo flappy en el proximo fotograma
        cmp x10, x1
        b.lo fi_actualizarVelocidadFlappy
        // Caso alturaFlappy en el proximo fotograma > AlturaSiguienteTubo
        mov x9, capacidadSaltoFlappy // Si hace falta saltar, pongo en la velocidad la velocidad que se adquiere al saltar (capacidadSaltoFlappy)
    fi_actualizarVelocidadFlappy:
        adr x10, velocidadFlappy
        str x9, [x10] // Guardo en memoria la nueva velocidad

        ldur lr, [sp] // Recupero el puntero de retorno del stack
        add sp, sp, #8 
        br lr // return
//



.endif
