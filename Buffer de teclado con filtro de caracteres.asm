.data
    buffer: .space 100       # Espacio para el buffer circular
    size:   .word 100
    head:   .word 0
    msg:    .asciiz "\nContenido del buffer: "

.text
main:
    # Habilitar interrupciones de teclado (bit 1 de Receiver Control)
    li $t0, 0xFFFF0000
    li $t1, 2
    sw $t1, 0($t0)

    # Habilitar interrupciones globales en Status Register (CP0)
    mfc0 $a0, $12
    ori  $a0, $a0, 0xFF01
    mtc0 $a0, $12

loop_principal:
    # Simulación de espera de 20 segundos
    li $v0, 30          # Get system time
    syscall
    move $s0, $a0       # Guardar tiempo inicial en ms

esperar_20s:
    li $v0, 30
    syscall
    subu $t0, $a0, $s0
    bltu $t0, 20000, esperar_20s

    # Imprimir y vaciar
    li $v0, 4
    la $a0, msg
    syscall
    jal vaciar_buffer
    j loop_principal

vaciar_buffer:
    la $t0, buffer
    lw $t1, head
    li $t2, 0           # Índice para vaciar
imprimir_loop:
    beq $t2, $t1, fin_vaciar
    addu $t3, $t0, $t2
    lb $a0, 0($t3)
    li $v0, 11
    syscall
    addi $t2, $t2, 1
    j imprimir_loop
fin_vaciar:
    sw $zero, head      # Resetear puntero
    jr $ra

# --- MANEJADOR DE INTERRUPCIONES ---
.ktext 0x80000180
    # Leer el carácter del teclado
    li $t0, 0xFFFF0004
    lb $k0, 0($t0)

    # Filtrar solo MAYÚSCULAS (A=65, Z=90)
    blt $k0, 65, salir_k
    bgt $k0, 90, salir_k

    # Guardar en buffer circular
    la $t1, buffer
    lw $t2, head
    addu $t3, $t1, $t2
    sb $k0, 0($t3)
    
    # Actualizar head (simplificado: lineal hasta 100)
    addi $t2, $t2, 1
    sw $t2, head

salir_k:
    eret