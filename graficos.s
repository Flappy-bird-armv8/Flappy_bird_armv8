/* Fuentes, Tiffany - Renison, Iván - Organización del computador - FaMAF */

.ifndef graficos_s
.equ graficos_s, 0

.include "datos.s" 

/* pintarPixel:
    Parámetros:
        x0 = Dirección base del arreglo
        w1 = Color
        x2 = Coordenada en x
        x3 = Coordenada en y
    
    Si el pixel está dentro de la pantalla lo pinta, si no no hace nada. Usar está función en lugar de 
    pintar directamente para evitar escribir erróneamente.

    Utiliza x9
    No modifica ningún parámetro.
 */
pintarPixel:
        cmp x2, SCREEN_WIDTH // Veo si el x es valido
        b.hs return_pintarPixel
        cmp x3, SCREEN_HEIGH // Veo si el y es valido
        b.hs return_pintarPixel 
        mov x9, SCREEN_WIDTH
        madd x9, x3, x9, x2 // x9 = (x3 * x9) + x2
        str w1, [x0, x9, lsl #2] // Guardo w1 en x0 + x9*2^2

    return_pintarPixel:
        br lr // return
//


/* pintarLineaVertical:
    Parámetros:
        x0 = Dirección base del arreglo
        w1 = Color
        x2 = Coordenada en x de la linea
        x3 = Coordenada en y del comienzo de la linea
        x4 = Coordenada en y del final de la linea
    
    Utiliza los registros usados por pintarPixel (x9).
    No modifica ningún parámetro.
 */
pintarLineaVertical:
        sub sp, sp, #16 // Guardo el puntero de retorno en el stack
        stur lr, [sp, #8]
        stur x3, [sp] // Guardo en el stack la coordenada en y del comienzo de la linea

    loop_pintarLineaVertical:
        cmp x3, x4
        b.gt end_loop_pintarLineaVertical
        bl pintarPixel
        add x3, x3, #1
        b loop_pintarLineaVertical

    end_loop_pintarLineaVertical:
        ldur lr, [sp, #8] // Recupero el puntero de retorno del stack
        ldur x3, [sp] // Recupero la coordenada en y del comienzo de la linea
        add sp, sp, #16 

        br lr // return
//


/* pintarLineaHorizontal:
    Parámetros:
        x0 = Dirección base del arreglo
        w1 = Color
        x2 = Coordenada en x del comienzo de la linea
        x3 = Coordenada en y de la linea
        x4 = Coordenada en x del final de la linea

    Utiliza los registros usados por pintarPixel (x9).
    No modifica ningún parámetro.
 */
pintarLineaHorizontal:
        sub sp, sp, #16 // Guardo el puntero de retorno en el stack
        stur lr, [sp, #8]
        stur x2, [sp] // Guardo en el stack la coordenada en x del comienzo de la linea 

    loop_pintarLineaHorizontal:
        cmp x2, x4
        b.gt end_loop_pintarLineaHorizontal
        bl pintarPixel
        add x2, x2, #1
        b loop_pintarLineaHorizontal

    end_loop_pintarLineaHorizontal:
        ldur lr, [sp, #8] // Recupero el puntero de retorno del stack
        ldur x2, [sp] // Recupero la coordenada en x del comienzo de la linea
        add sp, sp, #16 

        br lr // return
//


/* pintarRectangulo:
    Parámetros:
        x0 = Dirección base del arreglo
        w1 = Color
        x2 = Coordenada inicial en x
        x3 = Coordenada inicial en y
        x4 = Coordenada final en x
        x5 = Coordenada final en y

    Utiliza los registros usados por pintarPixel (x9).
    No modifica ningún parámetro.
 */
pintarRectangulo:
        sub sp, sp, #16 
        stur lr, [sp, #8] // Guardo el puntero de retorno en el stack
        stur x3, [sp] // Guardo x3 en el stack

    loop_pintarRectangulo: // loop para avanzar en y
        cmp x3, x5
        b.gt end_loop_pintarRectangulo
        bl pintarLineaHorizontal
        add x3, x3, #1
        b loop_pintarRectangulo
    
    end_loop_pintarRectangulo:
        ldur lr, [sp, #8] // Recupero el puntero de retorno del stack
        ldur x3, [sp] // Recupero x3 del stack
        add sp, sp, #16

        br lr // return
//


/* pintarCirculo
    Parámetros:
        x0 = Dirección base del arreglo
        w1 = Color
        x2 = Coordenada del centro en x
        x3 = Coordenada del centro en y
        x4 = Radio

    Utiliza x9, x10, x11, x12, x13, x14, x15, x16 y los registros utilizados por pintarPixel (x9).
    No modifica ningún parámetro.
 */
/* Funciona recorriendo el cuadrado mínimo que contiene al círculo, y en cada pixel decidiendo si pintar o no.
    La forma usual de saber si un punto (x, y) está en el circulo centrado en (x1, y1) de radio r es
    ver si la norma de la distancia entre el punto y el centro es menor que r.
    En formulas:
        ||(x, y) - (x1, y1)|| <= r
    Aplicando la definición de norma:
        sqrt((x - x1)^2 + (y - y1)^2) <= r
    Esto es equivalente a:
        (x - x1)^2 + (y - y1)^2 <= r^2

    Para hacer menos cálculos uso esta última formula.
 */
pintarCirculo:
        sub sp, sp, #8 // Guardo el puntero de retorno en el stack
        stur lr, [sp]

        mov x15, x2 // Guardo en x15 la condenada del centro en x
        mov x16, x3 // Guardo en x16 la condenada del centro en y
        add x10, x2, x4 // Guardo en x10 la posición final en x
        add x11, x3, x4 // Guardo en x11 la posición final en y
        mul x12, x4, x4 // x12 = r^2 // para comparaciones en el loop
        sub x2, x2, x4 // Pongo en x2 la posición inicial en x

    loop0_pintarCirculo: // loop para avanzar en x
        cmp x2, x10
        b.gt end_loop0_pintarCirculo
        sub x3, x11, x4
        sub x3, x3, x4 // Pongo en x3 la posición inicial en y

    loop1_pintarCirculo: // loop para avanzar en y
        cmp x3, x11
        b.gt end_loop1_pintarCirculo // Veo si tengo que pintar el pixel actual
        sub x13, x2, x15 // x13 = distancia en x desde el pixel actual al centro
        smull x13, w13, w13 // x13 = w13 * w13 // Si los valores iniciales estaban en el rango permitido, x13 = w13 (sumll es producto signado)
        sub x14, x3, x16 // x14 = distancia en y desde el pixel actual al centro
        smaddl x13, w14, w14, x13 // x13 = x14*x14 + x13 // x13 = cuadrado de la distancia entre el centro y el pixel actual
        cmp x13, x12
        b.gt fi_pintarCirculo 
        bl pintarPixel // Pinto el pixel actual

    fi_pintarCirculo:
        add x3, x3, #1
        b loop1_pintarCirculo

    end_loop1_pintarCirculo:
        add x2, x2, #1
        b loop0_pintarCirculo

    end_loop0_pintarCirculo:
        mov x2, x15 // Restauro en x2 la condenada del centro en x
        mov x3, x16 // Restauro en x3 la condenada del centro en y
        ldur lr, [sp] // Recupero el puntero de retorno del stack
        add sp, sp, #8 

        br lr // return
//

/* pintarFilaDeCiruclos:
    Parámetros:
        x0 = Dirección base del arreglo
        w1 = Color
        x2 = Coordenada inicial en x del centro
        x3 = Coordenada en y del centro
        x4 = Radio
        x5 = Separación entre círculos
        x6 = Coordenada final en x del centro

    Pinta una hilera de círculos desde x2 hasta x3, en la altura x3.

    Utiliza los registros utilizados por pintarCirculo (x9, x10, x11, x12, x13, x14, x15 y x16).
    Modifica x2.
 */
pintarFilaDeCirculos:
        sub sp, sp, #8 // Guardo el puntero de retorno en el stack
        stur lr, [sp]

    loop_pintarFilaDeCirculos:
        cmp x2, x6
        b.hi end_loop_pintarFilaDeCirculos
        bl pintarCirculo
        add x2, x2, x5
        b loop_pintarFilaDeCirculos
    end_loop_pintarFilaDeCirculos:

        ldur lr, [sp] // Recupero el puntero de retorno del stack
        add sp, sp, #8 
        br lr // return
//


/* pintarNube:
    Parámetros:
        x0 = Dirección base del arreglo
    
    Se encarga de pintar las nubes en la pantalla comenzando desde la altura en la variable alturaNube, y hasta
    la altura en la variable alturaArbusto. Hace una llamada a pintarCirculo para darle una forma semi-circular
    a las nubes.

    Utiliza los registros w1, x2, x3, x4 y x5 y los utilizados por pintarCirculo, pintarGrama (x9, x10, x11, x12, x13, x14, x15 y x16) 
    y pintarRectangulo(x9).
    No modifica ningun parámetro.
 */
pintarNube:
        sub sp, sp, #8
        stur lr, [sp]

        ldr w1, colorNube
        mov x3, alturaNube
        mov x5, alturaArbusto
        mov x4, xzr
        mov x2, xzr

    formaCircularNube:
        cmp x2, SCREEN_WIDTH
        b.hi restoDeLaNube
        add x4, x4, #15 // Aumenta el tamaño del radio en cada llamada
        bl pintarCirculo
        add x2, x2, x4
        add x2, x2, #15
        cmp x4, #100 // Mientras el tamaño del radio sea menor que 100 se siguen pintando círculos
        b.ls formaCircularNube
        sub x4, x4, #40 // Cuando el radio sea 100 se le resta 40 y se vuelven a pintar círculos
        b formaCircularNube

    restoDeLaNube:
        mov x2, xzr
        mov x4, SCREEN_WIDTH
        bl pintarRectangulo // Pinto la nube hasta la altura donde comienza la grama

        ldur lr, [sp]
        add sp, sp, #8

        br lr // return
//


/* pintarGrama:
    Parámetros:
        x0 = Dirección base del arreglo

    Se encarga de pintar la vegetación en el fondo de la imagen, utiliza alturaArbusto y alturaPiso
    para determinar en que parte de la pantalla pinta. Hace una llamada a pintarFilaDeCirculos para darle una forma semi-circular
    a los arbustos.

    Utiliza los registros w1, x2, x3, x4, x5, x6 y los utilizados por pintarFilaDeCirculos y 
    pintarRectangulo (x9, x10, x11, x12, x13, x14, x15 y x16).
 */
pintarGrama:
    sub sp, sp, #8
    stur lr, [sp]

    .equ radioGrandeGrama, 33
    .equ radioChicoRama, 28
    .equ tamanioBordeGrama, 3
    .equ separacionCirculosGrama, 70

    .equ radioGrandeInteriorGrama, radioGrandeGrama - tamanioBordeGrama
    .equ radioChicoInteriorRama, radioChicoRama - tamanioBordeGrama
    .equ separacionCirculosGrama_div_2, separacionCirculosGrama/2

    // Pinto los círculos grandes del borde
    ldr w1, colorArbustoBorde
    mov x2, #0
    mov x3, alturaArbusto
    mov x4, radioGrandeGrama
    mov x5, separacionCirculosGrama
    mov x6, SCREEN_WIDTH
    bl pintarFilaDeCirculos

    // Pinto los círculos chicos del borde
    mov x2, separacionCirculosGrama_div_2
    mov x4, radioChicoRama
    bl pintarFilaDeCirculos

    // Pinto los círculos grandes del interior
    ldr w1, colorArbusto
    mov x4, radioGrandeInteriorGrama
    mov x2, #0
    bl pintarFilaDeCirculos

    // Pinto los círculos chicos del interior
    mov x2, separacionCirculosGrama_div_2
    mov x4, radioChicoInteriorRama
    bl pintarFilaDeCirculos

    // Pinto abajo de los círculos
    mov x2, #0
    mov x3, alturaArbusto
    mov x4, SCREEN_WIDTH
    mov x5, alturaPiso
    bl pintarRectangulo
    bl pintarPiso

    ldur lr, [sp]
    add sp, sp, #8

    br lr // return
//


/* pintarPiso:
    Parámetros: 
        x0 = Dirección base del arreglo

    Se encarga de pintar el piso, comenzando desde la altura en la variable alturaPiso, y hasta el borde inferior de la pantalla.
    Utiliza los registros w1, x2, x3, x4, x5 y los que utiliza pintarRectangulo (x9).
 */
pintarPiso:
    sub sp, sp, #8
    stur lr, [sp]

    ldr w1, colorPiso
    mov x2, xzr
    mov x3, alturaPiso
    mov x4, SCREEN_WIDTH
    mov x5, SCREEN_HEIGH
    bl pintarRectangulo 

    ldur lr, [sp]
    add sp, sp, #8

    br lr // return
//


/* pintarFondo: 
    Parámetros:
        x0 = Dirección base del arreglo

    Se encarga de pintar el fondo de la imagen, y luego hace saltos a pintarNube y pintarGrama para agregar
    los detalles de las nubes y la vegetación al fondo.

    Utiliza los registros w1, x2, x3, x4, x5 y los que utiliza pintarRectangulo, pintarNube y pintarGrama (x9, x10, x11, x12, x13, x14, x15 y x16).
 */
pintarFondo:
        sub sp, sp, #8
        stur lr, [sp]

        ldr w1, colorCielo
        mov x2, xzr // coordenada en y
        mov x3, xzr // coordenada en x
        mov x4, SCREEN_WIDTH
        mov x5, alturaNube 
        bl pintarRectangulo // Pinto el cielo hasta la altura donde se encuentran las nubes 
        bl pintarNube
        bl pintarGrama

        ldur lr, [sp]
        add sp, sp, #8

        br lr // return
//


/* pintarTubo:
    Parámetros:
        x0 = Dirección base del arreglo
        x1 = Posición del centro del tubo en x
        x2 = Posición del centro del hueco del tubo en y

    Utiliza los registros w1, x3, x4, x5, x6, x9, x10, x11, x15, x16 y los utilizados por
    pintarRectangulo, degradadoTubosBoca y degradadoTubos (x9 y x13).
    No modifica ningún parámetro.
 */
/* Un poco del funcionamiento:
    Pinta dos cuadrados verdes
    Las coordenadas del cuadrado de abajo son:
        (x1 - anchoTubo/2, x2 + tamanioHuecoTubo/2) (x1 + anchoTubo/2, alturaPiso - 1).
    Las coordenadas del cuadrado de arriba son:
        (x1 - anchoTubo/2, 0) (x1 + anchoTubo/2, x2 - tamanioHuecoTubo/2).

    Pinta primero todo el tubo del color del borde, y después pinta el interior del tubo.
 */
pintarTubo:
    sub sp, sp, #8 // Guardo el puntero de retorno en el stack
    stur lr, [sp]

    .equ mitadDelAncho, anchoTubo/2
    .equ tercioDelAncho, anchoTubo/3
    .equ quintoDelAncho, anchoTubo/5
    .equ mitadTamanioHueco, tamanioHuecoTubo/2
    .equ mitadDelAncho_mas_anchoBorde, mitadDelAncho + anchoBordeDelTubo

    mov x10, x1 // Guardo la posición en x del centro del tubo en x10
    mov x11, x2 // Guardo la altura del centro del hueco del tubo en x11

    // Borde tubo de abajo // Pinto todo el tubo del color del borde, y después pinto el interior del color del tubo
    ldr w1, colorBordeTubo // Pongo en w1 el color del borde tubo
    sub x2, x10, mitadDelAncho_mas_anchoBorde
    add x4, x10, mitadDelAncho_mas_anchoBorde
    add x3, x11, mitadTamanioHueco // x3 = x11 + tamanioHuecoTubo/2
    .equ alturaPiso_menos_uno, alturaPiso - 1
    mov x5, alturaPiso_menos_uno
    bl pintarRectangulo

    // Interior tubo de abajo
    mov x15, x2  // se guardan los valores de x2 y x4
    mov x16, x4
    add x4, x2, tercioDelAncho
    add x2, x2, anchoBordeDelTubo
    add x3, x3, anchoBordeDelTubo
    bl degradadoTubos

    //parte superior del tubo de abajo (borde)
    ldr w1, colorBordeTubo
    sub x2, x15, #5
    add x4, x16, #5
    add x5, x3, quintoDelAncho
    bl pintarRectangulo

    //parte superior del tubo de abajo (interior)
    add x2, x2, #3
    sub x5, x5, #4
    bl degradadoTubosBoca
    mov x2, x15
    mov x4, x16

    // Borde del tubo de arriba
    ldr w1, colorBordeTubo // Pongo en w1 el color del borde tubo
    sub x5, x11, mitadTamanioHueco
    mov x3, xzr
    bl pintarRectangulo

    // Interior del tubo de arriba
    add x4, x2, tercioDelAncho
    add x2, x2, anchoBordeDelTubo
    sub x5, x5, anchoBordeDelTubo
    bl degradadoTubos

    //parte inferior del tubo de arriba (borde)
    ldr w1, colorBordeTubo
    sub x2, x15, #5
    sub x3, x5, quintoDelAncho
    add x4, x16, #5
    bl pintarRectangulo

    //parte inferior del tubo de arriba (interior)
    add x3, x3, #4
    add x2, x2, #3
    bl degradadoTubosBoca

    mov x1, x10 // Restauro la posición en x del centro del tubo a x1
    mov x2, x11 // Restauro la altura del centro del hueco del tubo a x2
    ldur lr, [sp] // Recupero el puntero de retorno del stack
    add sp, sp, #8 

    br lr // return
//


/* degradadoTubosBoca:
    Parámetros:
        x0 = Dirección base del arreglo
        x2 = Posición del principio del tubo en el eje x
        x3 = Posición del principio del tubo en el eje y
        x4 = Posición del final del tubo en el eje x
        x5 = Posición del final del tubo en el eje y

    Se encarga de darle el color de relleno a la parte superior del tubo(boca del tubo), divide el tubo en 3 partes y 
    pinta cada parte de un color distinto para darle un aspecto degradado.

    Utiliza los registros w1 y x16 y los utilizados por pintarRectangulo (x9) y pintarLineaVertical (x9 y x13).
    Modifica los parámetros x2 y x4.
 */
degradadoTubosBoca:
    sub sp, sp, #8
    stur lr, [sp]

    .equ tercioDelAncho, anchoTubo/3

    //Parte izquierda
    ldr w1, colorTuboParteIzquierda
    add x4, x2, tercioDelAncho
    bl pintarRectangulo

    //Reflejo
    ldr w1, colorReflejo
    mov x2, x4
    mov x4, x5
    bl pintarLineaVertical
    add x2, x2, #1
    bl pintarLineaVertical

    //Parte media
    ldr w1, colorTuboParteMedia
    add x2, x2, #1
    add x4, x2, tercioDelAncho
    bl pintarRectangulo

    //Parte derecha
    ldr w1, colorTuboParteDerecha
    mov x2, x4
    .equ anchoBordeDelTubo_menos_uno, anchoBordeDelTubo - 1
    add x4, x16, anchoBordeDelTubo_menos_uno
    bl pintarRectangulo

    ldur lr, [sp]
    add sp, sp, #8

    br lr // return
//


/* degradadoTubos:
    Parámetros:
        x0 = Dirección base del arreglo
        x2 = Posición del principio del tubo en el eje x
        x3 = Posición del principio del tubo en el eje y
        x4 = Posición del final del tubo en el eje x
        x5 = Posición del final del tubo en el eje y

    Se encarga de darle el color de relleno al tubo, divide el tubo en 3 partes y pinta cada parte de un color
    distinto para darle un aspecto degradado.

    Utiliza los registros w1, x6 y x16 y los utilizados por pintarRectangulo (x9) y pintarLineaVertical (x9 y x13).
    Modifica los parámetros x2 y x4.

 */
degradadoTubos:
    sub sp, sp, #8
    stur lr, [sp]

    .equ tercioDelAncho, anchoTubo/3

    //Parte izquierda
    ldr w1, colorTuboParteIzquierda
    bl pintarRectangulo

    //Reflejo
    ldr w1, colorReflejo
    mov x2, x4
    mov x4, x5
    bl pintarLineaVertical
    add x2, x2, #1
    bl pintarLineaVertical

    //Parte media
    ldr w1, colorTuboParteMedia
    add x2, x2, #1
    add x4, x2, tercioDelAncho
    bl pintarRectangulo

    //Parte derecha
    ldr w1, colorTuboParteDerecha
    add x4, x4, #1
    mov x2, x4
    sub x4, x16, anchoBordeDelTubo
    bl pintarRectangulo

    ldur lr, [sp]
    add sp, sp, #8

    br lr // return
//


/* pintarTubos:
    Parámetro:
        x0 = Dirección base del arreglo
    
    Pinta todos los tubos, mirando sus posiciones y tamaños en memoria.
    Utiliza los registros x1, x2, x12, x14 y los utilizados por pintarTubo (x3, x4, x5, x6, x9, x10, x11, x13, x15, y x16).
    No modifica ningún parámetro.
 */
pintarTubos: 
        sub sp, sp, #8 // Guardo el puntero de retorno en el stack
        stur lr, [sp]

        mov x12, xzr
        ldr x1, posicionEnXPrimerTubo
        adr x14, alturaTubos // x14 = dirección de memoria de alturaTubos

    loop_pintarTubos:
        cmp x12, cantidadDeTubos
        b.hs end_loop_pintarTubos
        ldr x2, [x14, x12, lsl #3]
        bl pintarTubo
        add x12, x12, #1
        add x1, x1, distanciaEntreTubos
        b loop_pintarTubos

    end_loop_pintarTubos:
        ldur lr, [sp] // Recupero el puntero de retorno del stack
        add sp, sp, #8 

        br lr // return
//


/* pintarFlappy:
    Parámetros:
        x0 = dirección base del arreglo

    Se encarga de dibujar al flappy centrado en las coordenadas (offSetEnXFlappy, alturaFlappy).
    Tanto los colores del flappy como su tamaño se pueden cambiar con los valores bajo datos flappy en el archivo datos.s

    Utiliza los registros w1, x2, x3, x4 y los utilizados por pintarCirculo (x9, x10, x11, x12, x13, x14, x15 y x16).
    No modifica ningún parámetro.
 */
pintarFlappy:
    sub sp, sp, #8 // Guardo el puntero de retorno en el stack
    stur lr, [sp]

    // cuerpo
    mov x2, offSetEnXFlappy
    ldr x3, alturaFlappy
    mov x4, radioFlappy 
    ldr w1, colorCuerpoFlappy 
    bl pintarCirculo

    // ala
    .equ offSetEnXFlappy_menos_radioFlapp, offSetEnXFlappy - radioFlappy
    .equ radioFlappy_div_2_menos_1, radioFlappy/2 - 1
    mov x2, offSetEnXFlappy_menos_radioFlapp
    mov x4, radioFlappy_div_2_menos_1
    ldr w1, colorAlaFlappy  
    bl pintarCirculo

    ldr w1, colorInteriorAlaFlappy
    sub x3, x3, #3
    sub x4, x4, #2
    bl pintarCirculo

    // ojo
    .equ radioFlappy_menos_4__div_2, (radioFlappy - 4)/2
    .equ offSetEnXFlappy_mas_radioFlappy_menos_4, offSetEnXFlappy + radioFlappy - 4
    sub x3, x3, #2  
    mov x4, radioFlappy_menos_4__div_2
    mov x2, offSetEnXFlappy_mas_radioFlappy_menos_4
    ldr w1, colorOjoFlappy
    bl pintarCirculo

    // pupila
    .equ radioFlappy_div_4, radioFlappy/4
    add x2, x2, #2
    mov x4, radioFlappy_div_4
    ldr w1, colorPupilaFlappy 
    bl pintarCirculo
 
    // boca
    .equ radioFlappy_div_2_menos_2, radioFlappy/2 - 2
    mov x4, radioFlappy
    mov x4, radioFlappy_div_2_menos_2
    ldr x3, alturaFlappy
    add x3, x3, x4
    ldr w1, colorBocaFlappy  
    bl pintarCirculo

    // labios
    sub x2, x2, x4  
    add x4, x4, x4
    add x4, x2, x4 
    ldr w1, colorPupilaFlappy
    bl pintarLineaHorizontal

    ldur lr, [sp] // Recupero el puntero de retorno del stack
    add sp, sp, #8 
        
    br lr // return
//

.endif
