.data
	instruccion: .asciiz "Ingrese un número n positivo: "
	salida: .asciiz "\nResultado de la función paridad {par=0 | impar=1): "

.text
#Función principal que se encarga de leer, hacer la llamada inicial, mostrar por pantalla los resultados y cerrar el programa.
main:
	#Muestra en pantalla el mensaje intruccion.
	li $v0, 4
	la $a0, instruccion
	syscall
	#Se lee un entero y se respalda en un registro.
	li $v0, 5
	syscall
	move $a0, $v0
	#Se verifica que sea positivo.
	bltz $a0, main
	#Llamada inicial.
	jal paridad
	#Muestra el mensaje antes de la salida.
    	move $t0, $v0
    	li $v0, 4
    	la $a0, salida
    	syscall
	#Imprime el resultado.
    	li $v0, 1
    	move $a0, $t0
    	syscall
    	#Cierra el programa.
    	li $v0, 10
    	syscall
#Función para calcular la paridad de manera recursiva.
paridad:
   	#Reservamos memoria y guardamos la dirección de retorno y el valor de n actual.
    	addi $sp, $sp, -8
	sw $ra, 0($sp)
	sw $a0, 4($sp)
   	#Caso base n = 0 y prepara $v0 para las operaciones tras retornar las llamadas.
   	li $v0, 0
   	beq $a0, $zero, retornar
   	#Caso recusrivo, nueva llamada paridad(n - 1)
   	addi $a0, $a0, -1
   	jal paridad
   	#Lleva a cabo la operación de retorno (1 - paridad(n - 1) y determina la paridad de 
   	li $t1, 1               
   	sub $v0, $t1, $v0
#Se encarga de restaurar la memoria y retornar las llamadas.
retornar:
    	#Restaura la memoria y retorna la llamada función paridad.
    	lw $a0, 4($sp)
    	lw $ra, 0($sp)
    	addi $sp, $sp, 8
    	jr $ra
