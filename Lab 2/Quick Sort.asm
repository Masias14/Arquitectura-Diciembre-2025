.data
    vector:      .word 12, 5, 8, -1, 300, 10, 7, 9
    tamaño:      .word 8
    mensaje1:    .asciiz "Vector original: "
    mensaje2:    .asciiz "\nVector ordenado: "
    espacio:     .asciiz " "
    newline:     .asciiz "\n"

.text
#Función principal.
main:
    	# Mostrar vector original
    	la $a0, mensaje1
    	li $v0, 4
    	syscall
    	#Llamar a la función que imprime un vector.
    	jal escribir_vector
    	# Preparar parámetros para quicksort.
    	la $a0, vector
    	li $a1, 0
    	lw $t0, tamaño
    	addi $a2, $t0, -1
    	# Ordenar el vector.
    	jal quicksort
    	# Mostrar vector ordenado
    	la $a0, mensaje2
    	li $v0, 4
    	syscall
    	#Llamar a la función que imprime un vector.
    	jal escribir_vector
    	#Termina el progrma.
    	li $v0, 10
    	syscall
#Función que se encarga de imprimir.
escribir_vector:
    	#Guardar $ra en pila porque llamamos a syscalls.
    	addi $sp, $sp, -4
    	sw $ra, 0($sp)
    	#Prepara el ciclo.
    	la $t0, vector
    	lw $t1, tamaño
    	li $t2, 0
#Ciclo que permite recorrer el vector.   
escribir_ciclo:
	#Condición que verifica la salida del ciclo.
    	beq $t2, $t1, terminar_escribir
    	#Imprime elemento actual.
    	lw $a0, 0($t0)
    	li $v0, 1
    	syscall
    	#Imprime el espacio separador.    	
    	la $a0, espacio
    	li $v0, 4
    	syscall
    	#Avanza al siguiente elemento
    	addi $t0, $t0, 4
    	addi $t2, $t2, 1
    	j escribir_ciclo
#Cierra la recursión.
terminar_escribir:
    	# Imprimir salto de línea al final
    	la $a0, newline
    	li $v0, 4
    	syscall
    	#Restauramos pila y retornamos
    	lw $ra, 0($sp)
    	addi $sp, $sp, 4
    	jr $ra
#Función que ordena el vector.
quicksort:
    	#Caso base: izquiera = derecha.
    	slt $t0, $a1, $a2
    	beq $t0, $zero, fin_qs
    	#Guarda contexto necesario en la pila.
    	addi $sp, $sp, -16
    	sw $ra, 12($sp)
    	sw $a1, 8($sp)
    	sw $a2, 4($sp)
    	#$sp+0 se usará para guardar el pivote después
    	# Llamar a partición para obtener índice del pivote
    	jal particion
    	move $t1, $v0
    	#Ordenar subvector izquierdo: quicksort(vector, izquierda, pivote-1).
    	lw $a1, 8($sp)
    	addi $a2, $t1, -1
    	sw $t1, 0($sp)
    	jal quicksort
    	#Ordena subvector derecho: quicksort(vector, pivote+1, derecha).
    	lw $t1, 0($sp)
    	addi $a1, $t1, 1
    	lw $a2, 4($sp)
    	jal quicksort
    	#Restaura contexto y retorna.
    	lw $ra, 12($sp)
    	addi $sp, $sp, 16
#Returna el quickshort.
fin_qs:
    	jr $ra
#Se encarga de obtener el pivote.
particion:
    	#Elige el último elemento como pivote: pivote = vector[derecha].
    	sll $t0, $a2, 2
    	add $t0, $t0, $a0
    	lw $t1, 0($t0)
    	# Inicializar i y j.
    	move $t2, $a1
    	move $t3, $a1
#Verifica y compara el pivote para intercambiar.
for_loop:
	#Verifica si j < derecha, si no se cumple se sale del bucle.
    	slt $t4, $t3, $a2
    	beq $t4, $zero, intercambiar_pivote
    	#Carga vector[j].
    	sll $t4, $t3, 2
    	add $t4, $t4, $a0
    	lw $t5, 0($t4)
    	#Compara vector[j] con pivote. Si el pivote es mayor, intercambia V[i] con V[j] y aumenta i, sino aumenta el valor de j.
    	slt $t6, $t5, $t1
    	beq $t6, $zero, siguiente_iteración
    	#Intercambia vector[i] y vector[j].
    	sll $t7, $t2, 2
    	add $t7, $t7, $a0
    	lw $t8, 0($t7)
    	sw $t5, 0($t7)
    	sw $t8, 0($t4)
    	#i++
    	addi $t2, $t2, 1
#Aumenta el contador j.
siguiente_iteración:
	#j++
    	addi $t3, $t3, 1
    	j for_loop
#Intercambia el pivote.
intercambiar_pivote:
    	# Colocar pivote en posición correcta: intercambiar vector[i] y vector[derecga]
    	sll $t7, $t2, 2
    	add $t7, $t7, $a0
    	lw $t8, 0($t7)
    	sw $t1, 0($t7)
    	sw $t8, 0($t0)
    	#Retorna el valor del pivote y vuelve a quickshort.
    	move $v0, $t2
    	jr $ra
