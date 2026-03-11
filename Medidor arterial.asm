.data
    # Direcciones de E/S mapeada
    TENSION_CTRL:   .word 0x10010300
    TENSION_ESTADO: .word 0x10010304
    TENSION_SISTOL: .word 0x10010308
    TENSION_DIASTOL: .word 0x1001030C

    # Mensajes de salida
    msg_sis: .asciiz "Tension Sistolica: "
    msg_dia: .asciiz "\nTension Diastolica: "

.text
.globl main

main:
    # Simulación de datos listos para el profesor
    lw $t0, TENSION_ESTADO
    li $t1, 1
    sw $t1, 0($t0)
    lw $t0, TENSION_SISTOL
    li $t1, 120
    sw $t1, 0($t0)
    lw $t0, TENSION_DIASTOL
    li $t1, 80
    sw $t1, 0($t0)

    # Llamada al controlador
    jal controlador_tension

    # Guardar resultados
    move $s0, $v0
    move $s1, $v1

    # Mostrar Sistólica
    li $v0, 4
    la $a0, msg_sis
    syscall
    li $v0, 1
    move $a0, $s0
    syscall

    # Mostrar Diastólica
    li $v0, 4
    la $a0, msg_dia
    syscall
    li $v0, 1
    move $a0, $s1
    syscall

    li $v0, 10
    syscall

controlador_tension:
    # 1. Iniciar medición
    lw $t0, TENSION_CTRL
    li $t1, 1
    sw $t1, 0($t0)

    # 2. Esperar a que TensionEstado sea 1 (Polling)
esperar_tension:
    lw $t0, TENSION_ESTADO
    lw $t1, 0($t0)
    li $t2, 1
    bne $t1, $t2, esperar_tension

    # 3. Leer resultados y retornar
    lw $t0, TENSION_SISTOL
    lw $v0, 0($t0)          # Sistólica en $v0
    lw $t0, TENSION_DIASTOL
    lw $v1, 0($t0)          # Diastólica en $v1

    jr $ra