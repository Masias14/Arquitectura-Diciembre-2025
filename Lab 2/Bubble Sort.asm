.data
	vector:      .word 12, 5, -8, 1, 3, 1000, 7, 9
    	tamaño:      .word 8
    	mensaje1:    .asciiz "Vector original: "
    	mensaje2:    .asciiz "\nVector ordenado: "
    	espacio:     .asciiz " "
    	newline:     .asciiz "\n"

.text

main:
	#Mostrar ek vetor original.
    	la $a0, mensaje1
    	li $v0, 4
    	syscall
    	jal escribir_vector
    	#Imprimie el salto de línea al final.
    	la $a0, newline
    	li $v0, 4
    	syscall
    	#Bubble Sort.
    	la $a0, vector
    	lw $a1, tamaño
    	jal bubblesort
    	#Muestra el vector ordenado.
    	la $a0, mensaje2
    	li $v0, 4
    	syscall
    	jal escribir_vector
	#Termina el programa.
    	li $v0, 10
    	syscall
#Ordenamiento burbuja.
bubblesort:
	#El limite de los ciclos.
    	addi $t0, $a1, -1      
ciclo_externo:
	#Verifica si se termina el ciclo exterior.
    	blez $t0, terminar_bubble
    	#Incializa i en 0. 
    	li $t1, 0              
ciclo_interno:
	#Verifica si i = j, si es verdad se reincia i y j se le suma uno.
    	beq $t1, $t0, siguiente_externo
    	#De no ser verda, guarda las casillas V[i] y V[j].
    	sll $t2, $t1, 2
    	add $t2, $t2, $a0
    	lw $t3, 0($t2)           
    	lw $t4, 4($t2)           
    	#Se comparan, de ser verdad, pasa a la siguiente iteración.
    	ble $t3, $t4, no_intercambiar   
    	#De no ser verdad se intercambian V[i] y V[j]
    	sw $t4, 0($t2)           
    	sw $t3, 4($t2)
no_intercambiar:
	#i++
    	addi $t1, $t1, 1
    	j ciclo_interno
siguiente_externo:
	#j++
    	addi $t0, $t0, -1
    	j ciclo_externo
terminar_bubble:
	#Retorna despues de haber ordenado.
    	jr $ra

#Subrutina para escribir el vector original y el ordenado.
escribir_vector:
	#Prepara el ciclo.
    	la $t8, vector
    	lw $t9, tamaño
    	li $t7, 0
escribir_ciclo:
	#Verifica si el indice es igual al tamaño del vector, si es verdad termina el ciclo.
    	beq $t7, $t9, ciclo_termina
    	#De ser falso, muestra el elemento actual del vector.
    	lw $a0, 0($t8)
    	li $v0, 1
    	syscall
    	#Muestra un espacio separador para el formato de salida.
    	la $a0, espacio
    	li $v0, 4
    	syscall
    	#Se ajuntan el indice en 4 bytes pero como decir i++, para acceder a la siguiente casilla del vector.
    	addi $t8, $t8, 4
    	addi $t7, $t7, 1
    	j escribir_ciclo
ciclo_termina:
	#Retorna a main con el vector ya escrito.
    	jr $ra
