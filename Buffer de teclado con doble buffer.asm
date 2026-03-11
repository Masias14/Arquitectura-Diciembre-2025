.data
    bufA:  .space 50
    bufB:  .space 50
    headA: .word 0
    headB: .word 0
    flag:  .word 0          # 0 = Escribir en A, 1 = Escribir en B
    msgA:  .asciiz "\nVaciando Buffer A: "
    msgB:  .asciiz "\nVaciando Buffer B: "

.text
main:
    # Habilitar teclado
    li $t0, 0xFFFF0000
    li $t1, 2
    sw $t1, 0($t0)
    mfc0 $a0, $12
    ori  $a0, $a0, 0xFF01
    mtc0 $a0, $12

loop_pingpong:
    li $v0, 30
    syscall
    move $s0, $a0

esperar_10s:
    li $v0, 30
    syscall
    subu $t0, $a0, $s0
    bltu $t0, 10000, esperar_10s

    # Cambiar bandera y vaciar el anterior
    lw $t0, flag
    xori $t0, $t0, 1    # Alternar 0 <-> 1
    sw $t0, flag

    beq $t0, 1, imprimir_A
    # Si ahora la bandera es 0, significa que acabamos de llenar el B
    li $v0, 4
    la $a0, msgB
    syscall
    jal vaciar_B
    j loop_pingpong

imprimir_A:
    li $v0, 4
    la $a0, msgA
    syscall
    jal vaciar_A
    j loop_pingpong

# Funciones de vaciado omitidas por brevedad (similares al Ej 1)
vaciar_A: sw $zero, headA; jr $ra
vaciar_B: sw $zero, headB; jr $ra

# --- MANEJADOR DE INTERRUPCIONES ---
.ktext 0x80000180
    li $t0, 0xFFFF0004
    lb $k0, 0($t0)      # Leer tecla

    lw $k1, flag
    beq $k1, 1, a_buffer_B

    # Guardar en A
    la $t1, bufA
    lw $t2, headA
    addu $t3, $t1, $t2
    sb $k0, 0($t3)
    addi $t2, $t2, 1
    sw $t2, headA
    j salir_int

a_buffer_B:
    la $t1, bufB
    lw $t2, headB
    addu $t3, $t1, $t2
    sb $k0, 0($t3)
    addi $t2, $t2, 1
    sw $t2, headB

salir_int:
    eret