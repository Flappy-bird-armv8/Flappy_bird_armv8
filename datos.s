/* Fuentes, Tiffany - Renison, Iván - Organización del computador - FaMAF */

.ifndef datos_s
.equ datos_s, 0 


.data
bufferSecundario: .skip BYTES_FRAMEBUFFER

delay: .dword 0xfffff  // A mayor número mas lento va la animación

semilla: .dword 0x95df41b05ee16cc2




// Tamaños:

// Fondo
.equ alturaPiso, 460
.equ alturaNube, 250
.equ alturaArbusto, 420

// Tubos
.equ anchoTubo, 40
.equ tamanioHuecoTubo, 100
.equ anchoBordeDelTubo, 3
.equ distanciaEntreTubos, 150
.equ velocidadTubos, 8 // Cuanto avanzan los tubos hacia la izquierda por fotograma

.equ cantidadDeTubos, SCREEN_WIDTH/distanciaEntreTubos + 1
.equ alturaTuboInicial, alturaPiso/2
.equ difAlturasTubos, 5              // 2^difAlturasTubos es la máxima diferencia de altura que puede haber entre un tubo y otro
posicionEnXPrimerTubo: .dword 200
alturaTubos: .skip 8*cantidadDeTubos // Arreglo con la altura del centro de los tubos

// Flappy
.equ radioFlappy, 12
.equ offSetEnXFlappy, 30 
.equ gravedad, 3               // Gravedad positiva tira hacia abajo
.equ capacidadSaltoFlappy, -8  // La velocidad que adquiere cuando hace un salto

alturaFlappy: .dword 250   
velocidadFlappy: .dword 0 // Positivo se mueve hacia abajo, negativo se mueve hacia arriba

/* Los tamaños en memoría se modifican durante la ejecución */




// Colores:

// Fondo
colorCielo: .word 0xd5f4f3              // Celeste
colorNube: .word 0xf8f8ff               // Blanco
colorArbusto: .word 0x6ead6a            // Verde claro
colorArbustoBorde: .word 0x51854d       // Verde oscuro
colorPiso: .word 0xdbb368               // Marron claro

// Tubos
colorBordeTubo: .word 0x0033472f        // Verde oscuro
colorTuboParteIzquierda: .word 0x9ccc65 // Verde
colorTuboParteMedia: .word 0x8bc34a     // Verde
colorTuboParteDerecha: .word 0x7cb342   // Verde
colorReflejo: .word 0xfefffe            // Blanco

// Flappy
colorCuerpoFlappy: .word 0x000000       // Negro
colorBocaFlappy: .word 0xf0530f         // Naranja
colorPupilaFlappy: .word 0x000000       // Negro
colorOjoFlappy: .word 0xffffff          // Blanco
colorAlaFlappy: .word 0xfAd30f          // Amarillo
colorInteriorAlaFlappy: .word 0xffffff  // Blanco




// Pantalla:

dir_frameBuffer: .dword 0 // Variable para guardar la dirección de memoria del comienzo del frame buffer

.equ SCREEN_WIDTH, 640
.equ SCREEN_HEIGH, 480
.equ SCREEN_PIXELS, SCREEN_WIDTH * SCREEN_HEIGH
.equ BYTES_PER_PIXEL, 4
.equ BITS_PER_PIXEL, 8 * BYTES_PER_PIXEL
.equ BYTES_FRAMEBUFFER, SCREEN_PIXELS * BYTES_PER_PIXEL




.endif
