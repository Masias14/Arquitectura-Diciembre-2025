.data
    # Direcciones de memoria simuladas
    LUZ_CONTROL: .word 0x10010100 # Cambiadas a zona de datos segura para simuladores
    LUZ_ESTADO:  .word 0x10010104
    LUZ_DATOS:   .word 0x10010108

    # Mensajes de salida
    msg_init: .asciiz "Sensor inicializado. Esperando hardware...\n"
    msg_val:  .asciiz "Luminosidad leída: "
    msg_err:  .asciiz "\nEstado (0=OK, -1=Error): "

.text

main:
    # Ponemos "1" en Estado y "750" en Datos para que el código avance
    lw $t0, LUZ_ESTADO
    li $t1, 1
    sw $t1, 0($t0)
    
    lw $t0, LUZ_DATOS
    li $t1, 750
    sw $t1, 0($t0)

    # 1. Llamar a los procedimientos del ejercicio
    jal InicializarSensorLuz
    jal LeerLuminosidad

    # Guardar resultados
    move $s0, $v0  
    move $s1, $v1  

    # 2. Mostrar resultados por pantalla
    li $v0, 4
    la $a0, msg_val
    syscall

    li $v0, 1
    move $a0, $s0
    syscall

    li $v0, 4
    la $a0, msg_err
    syscall

    li $v0, 1
    move $a0, $s1
    syscall

    # Fin del programa
    li $v0, 10
    syscall

InicializarSensorLuz:
    lw $t8, LUZ_CONTROL
    li $t9, 0x1
    sw $t9, 0($t8)          # Escribir 0x1 (Inicializar)

esperar_listo:
    lw $t8, LUZ_ESTADO
    lw $t9, 0($t8)          # Leer estado
    li $t7, 1
    bne $t9, $t7, esperar_listo # Bucle de espera activa (Polling)
    jr $ra

LeerLuminosidad:
    lw $t8, LUZ_ESTADO
    lw $t9, 0($t8)          # Comprobar estado antes de leer

    li $t7, -1
    beq $t9, $t7, error_hw

    lw $t8, LUZ_DATOS
    lw $v0, 0($t8)          # Retornar valor leído
    li $v1, 0               # Retornar código OK
    jr $ra

error_hw:
    li $v0, 0
    li $v1, -1              # Retornar código Error
    jr $ra