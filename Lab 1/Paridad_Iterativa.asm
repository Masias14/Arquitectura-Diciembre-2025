.data

	instruccion: .asciiz "Ingrese un numero n positivo: "
	salida: .asciiz "\nResultado de paridad (0=Par, 1=Impar): "

.text

main:
	#Muestra en pantalla el mensaje intruccion.
	li $v0, 4
	la $a0, instruccion
	syscall
	#Se lee un entero y se respalda en un registro.
	li $v0, 5
	syscall
	move $t0, $v0
	#Se verifica que sea positivo.
	bltz $t0, main
	#El contador que se inicializa en cero
	#Llevará el control de la paridad
    	li $t1, 0

#Se encarga de calcular la paridad
ciclo:
	#Se verifica la condicion de salida.
	#El ciclo se efectuará siempre y cuando n > 0
    	blez $t0, fin_ciclo
	#Se hace la resta 1 - paridad(n-1) en su versión iterativa.
    	li $t2, 1
    	sub $t1, $t2, $t1
	#Se reduce en uno el n que el ciclo termine cuando n = 0.
  	addi $t0, $t0, -1
  	#Salta a ciclo para iniciar de nuevo la función.
 	j ciclo

#Se encarga de mostrar la salida cuando termina el ciclo.
fin_ciclo:
	#Muestra por pantalla el mensaje salida.
	li $v0, 4
	la $a0, salida
	syscall
	#Muestra 1 o 0 por pantalla según sea el caso.
  	move $a0, $t1
  	li $v0, 1
   	syscall

#Se encarga de cerrar el programa.
exit:
	li $v0, 10
	syscall
