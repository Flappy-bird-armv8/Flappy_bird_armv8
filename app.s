/* Fuentes, Tiffany - Renison, Iván - Organización del computador - FaMAF */

.include "datos.s"
.include "graficos.s"
.include "logica.s"


.globl main


/*
    Para que la imagen se vea bien, todo lo que se pinta en cada fotograma se pinta en un buffer secundario,
    y en cada fotograma, después de que se pintan las cosas en este buffer secundario, se pasa todo el
    contenido al frame-buffer.
    Ese buffer secundario está declarado en datos.s al comienzo del todo, para que no quede en medio de
    otras cosas en la memoria.
 */
/* actualizarFrameBuffer:
    Parámetros:
        x0 = Dirección del buffer secundario

    Copia todo lo que hay en el buffer secundario al frame-buffer.
    Se ejecuta una vez por fotograma.
    La dirección del frame-buffer debe estar en dir_frameBuffer.

    No modifica ningún parámetro.
    Utiliza x9, x10 y x11.
 */
.equ SCREEN_PIXELS_div_2_menos_1, SCREEN_PIXELS/2 - 1
screen_pixels_div_2_menos_1: .dword SCREEN_PIXELS_div_2_menos_1 // Último indice tomando los elementos como dword
actualizarFrameBuffer:
        ldr x9, dir_frameBuffer
        ldr x10, screen_pixels_div_2_menos_1
    loop_actualizarFrameBuffer:
        cmp x10, #0
        b.lt end_loop_actualizarFrameBuffer
        ldr x11, [x0, x10, lsl #3] // Voy copiando los colores de a 2
        str x11, [x9, x10, lsl #3]
        sub x10, x10, #1
        b loop_actualizarFrameBuffer
    end_loop_actualizarFrameBuffer:
        br lr // return
//


/* crearDelay:
    Hace un gran loop para crear delay, el tiempo de delay depende de la constante delay.

    Utiliza x9.
 */
crearDelay:
        ldr x9, delay
    loop_crearDelay:
        subs x9, x9, 1
        b.ne loop_crearDelay

        br lr // return
//


/* main:
    Parámetros:
        x0 = Dirección base del frame-buffer

    Función que se debe ejecutar para iniciar el flappy-bird.
 */
/* Detalles del funcionamiento:
    Al comienzo guarda la dirección de memoria de frame-buffer en memoria, pone en x0 la dirección del
    buffer secundario para que la puedan usar las funciones que pintan cosas.
    Luego entra en un loop infinito que se ejecuta una vez por fotograma. En este loop, en cada
    iteración, primero pinta todo, luego actualiza en memoria valores internos que se tienen que
    actualizar, y por último hace un delay para que el siguiente fotograma no empiece demasiado rápido.
 */
main:
        adr x1, dir_frameBuffer
        str x0, [x1] // Guardo la dirección de memoria del frame-buffer en dir_frameBuffer
        ldr x0, =bufferSecundario // Pongo en x0 la dirección base del buffer secundario

        bl inicializarTubos

    gameLoop: 

        bl pintarFondo
        bl pintarTubos
        bl pintarFlappy

        bl actualizarFrameBuffer

        bl actualizarVelocidadFlappy
        bl actualizarAlturaFlappy
        bl moverTubos

        bl crearDelay

        b gameLoop
//
