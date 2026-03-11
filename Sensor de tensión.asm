.data
    PRESION_CTRL:   .word 0x10010200
    PRESION_ESTADO: .word 0x10010204
    PRESION_DATOS:  .word 0x10010208

    msg_val:    .asciiz "\nPresion leida: "
    msg_status: .asciiz "\nEstado final: "
    msg_retry:  .asciiz "\nError detectado. Reintentando..."

.text
.globl main

main:
    # --- Simulación de error inicial ---
    lw $t0, PRESION_ESTADO
    li $t1, -1
    sw $t1, 0($t0)
    
    lw $t0, PRESION_DATOS
    li $t1, 120
    sw $t1, 0($t0)

    # 1. Inicializar y Leer
    jal InicializarSensorPresion
    jal LeerPresion

    move $s0, $v0
    move $s1, $v1

    # 2. Salida por pantalla
    li $v0, 4
    la $a0, msg_val
    syscall
    li $v0, 1
    move $a0, $s0
    syscall

    li $v0, 4
    la $a0, msg_status
    syscall
    li $v0, 1
    move $a0, $s1
    syscall

    li $v0, 10
    syscall

InicializarSensorPresion:
    lw $t8, PRESION_CTRL
    li $t9, 0x5
    sw $t9, 0($t8)
poll_presion:
    lw $t8, PRESION_ESTADO
    lw $t9, 0($t8)
    li $t7, 0
    beq $t9, $t7, poll_presion
    jr $ra

LeerPresion:
    addiu $sp, $sp, -8
    sw $ra, 0($sp)
    sw $s2, 4($sp)          # Guardar $s2 (contador)

    li $s2, 3               # Límite de 3 reintentos

intentar_lectura:
    lw $t8, PRESION_ESTADO
    lw $t9, 0($t8)
    li $t7, -1
    bne $t9, $t7, lectura_ok

    # Lógica de reintento
    beq $s2, $zero, error_final
    addi $s2, $s2, -1
    
    li $v0, 4
    la $a0, msg_retry
    syscall

    # Simulación de recuperación para el profesor
    beq $s2, 1, corregir_hw 
    j reintentar

corregir_hw:
    lw $t0, PRESION_ESTADO
    li $t1, 1
    sw $t1, 0($t0)

reintentar:
    jal InicializarSensorPresion
    j intentar_lectura

lectura_ok:
    lw $t8, PRESION_DATOS
    lw $v0, 0($t8)
    li $v1, 0
    j fin_leer

error_final:
    li $v0, 0
    li $v1, -1

fin_leer:
    lw $ra, 0($sp)
    lw $s2, 4($sp)
    addiu $sp, $sp, 8
    jr $ra