.data
###########################################################   MENSAJES  #################################################################################################################
mensajeRuta:		.asciiz "\n Ingrese ruta del archivo que desea cargar: \n"
			.align 2
mensajeIngresarPalabra:	.asciiz "\n Ingrese la palabra a buscar en la sopa de letras:\n "
			.align 2
mensajeEncontrada:	.asciiz "La palabra fue encontrada en: "
			.align 2
mensajeNoEncontrada:	.asciiz "\n No se encontró la palabra que busca\n"
			.align 2
mensajeBuscarOtra:	.asciiz "\n ¿Quiere buscar otra Palabra?\n Ingrese (y) para continuar buscando palabras\n Ingrese (n) para no buscar mas palabras\n"
			.align 2
mensajeOpciones:		.asciiz "\nSeleccione una opción valida (y) ó (n)\n"
			.align 2
fila:			.asciiz "\n fila: "
			.align 2
columna:			.asciiz "\n columna: "
			.align 2
mensajeFinalizar:		.asciiz "... Terminando ejecución del programa...\n"
			.align 2
			
#########################################################################################################################################################################################

opc1:			.asciiz "y"					# Caracter de y
			.align 2
opc2:			.asciiz "n"					# Caracter de n
			.align 2
bufferPalabra:		.space 100 					# Dirección de las palabras que escribirá el usuario
			.align 2
bufferBuscarPalabra:	.space 3						# Dirección de la respuesta a la pregunta de si quiere buscar otra palabra (y o n)
			.align 2
archivo: 		.space 5054					# Dirección de la url del archivo ingresada por el user
			.align 2
archivoModificado:	.space 5054					# Dirección del archivo ingresado por el user pero sin el \n
			.align 2
spaces:			.asciiz ""     					#aquí se almacenan los caracteres leidos del archivo.
			
#########################################################################################################################################################################################
.text
main: 									# Subrutina: main (Inicio del Programa)
	jal	mainMenu 						# rubtina principal, jump and link
	j 	exit  
mainMenu: 								# Subrutina: menu principal
	addi $sp, $sp, -4							# Copia de seguridad de la dirección de la función que llama, para devolvernos en dado caso
	sw $ra, 0($sp)
	         
solicitarArchivo: 							# solicitamos al usuario que ingrese la ruta del archivo
	add $t1, $zero, $zero 						# guardaremos la dirección del buffer de entrada de la url del archivo
	add $t2, $zero, $zero 						# guardaremos la dirección donde almacenaremos el archivo sin \n (enter)
	add $t3, $zero, $zero 						# guardaremos la dirección de la url del archivo sucio
	add $t4, $zero, $zero 						# guardaremos la dirección de la url del archivo limpio
	add $t5, $zero, $zero 						# guardaremos la bandera \n (enter)
	add $t6, $zero, $zero 						# guardaremos el caracter leido de la url del archivo sucio
	
	li $v0, 4							# print string, $a0 = dirección de cadena terminada en nulo para imprimir
	la $a0,	mensajeRuta						# Mensaje de pedir archivo
	syscall

	li $v0, 8 							# leer string (para leer la url de la ruta del archivo)
    	la $a0, archivo							# $a0 = dirección del bufer de entrada (la direcciòn de "buffer" apuntará a la url)
    	li $a1, 1024							# Espacio maximo de cantidad de caracteres de la ruta del archivo
    	syscall
        
    	la $t1, archivo 							# cargamos indefinidamente en t1 la dirección de la url del archivo sucio
    	la $t2, archivoModificado 						# cargamos indefinidamente en t2 la dirección donde se alojará la url limpia
  	add $t3, $t1, $zero 						# hacemos una copia
  	add $t4, $t2, $zero 						# hacemos una copia
	addi $t5, $t5, 10  						# para saber cuando hemos llegado al final de la cadena ingresada por el user
                             
editarArchivo:	 							# remover de la la url o ruta o nombre del archivo el enter \n  	
	lbu $t6, 0($t3)							# $t6, almacena el caracter leido de t3, es decir caracter de la url que limpiaremos
	beq $t6, $t5, verificarArchivo 					# si (caracter == \n, entonces finalizamos la lectura y validaremos si es un archivo correcto
	sb $t6, 0($t4) 							# cpu -> memoria, enviamos el caracter leído y diferente de \n a la dirección del archivoModificado
	addi $t3, $t3, 1 							# avanzamos al siguiente caracter de la url que estamos limpiando
	addi $t4, $t4, 1 							# avanzamos a una posición disponible para guardar el siguiente caracter en archivoModificado
	j editarArchivo							# iteramos	
			
verificarArchivo:								# validamos si la ruta del archivo es correcta			
	add $t3, $zero, $zero						# reiniciamos, antes aqui estaba la copia del archivo sucio
	add $t4, $zero, $zero						# reiniciamos, antes aqui estaba la copia del archivo limpio
	add $s4, $t2, $zero						# guardamos la direccion del archivo de la sopa de letras INMUTABLE
	add $t2, $zero, $zero						# reseteando variable
        
	li $v0, 13							# abrir archivo, v0 contiene el descriptor del archivo
	la $a0, archivoModificado						# a0 = dirección del bufer de entrada (url limpia del archivo que ingresó el usuario)
	li $a1, 0							# Modo lectura
	li $a2, 0
	syscall
	
	add $s0, $v0, $zero						# guardamos en s0 el descriptor
	slt $t1, $v0, $zero						# si (v0 < 0)? t1=1: t1=0;
	bne $t1, $zero, solicitarArchivo 					# Si no encuentra el archivo, vuelve a preguntar por archivo, si( t1 != 0) solicitarArchivo
										# El archivo existe! Copiar datos a memoria									# Lectura del archvo
	li $v0, 14   							# lee datos desde el archivo
	add $a0, $s0, $zero						# descriptor del archivo a0 = s0
	la $a1, spaces							# dirección del buffer de entrada (hace referencia a la dirección de memoria donde inicia el contenido 
	li $a2, 5054							# cantidad maxima de caracteres que serán volcados del archivo a memoria
	syscall
	
	add $s5, $v0, $zero						# guardamos la cantidad de caracteres INMUTABLE
	add $a0, $s0, $zero						# pasamos el descriptor 
	li $v0, 16							# cerrar archivo
	syscall			
	
	add $s2, $a1, $zero						# Base del buffer del contenido del archivo INMUTABLE
	add $t0, $s2, $zero						# hacemos una copia del contenido para recorrer el buffer
	
	addi $t5, $zero, 13  						# para saber cuando hemos llegado al final de la fila
	
solicitarPalabras:													
	add $t1, $zero, $zero						# Iniciando temporales en 0 para volver a leer palabras en caso de incumplir
	
	li $v0, 4							# print string, $a0 = dirección de cadena terminada en nulo para imprimir
	la $a0,	mensajeIngresarPalabra						# Mensaje para pedir las palabras
	syscall								# para que se ejecute el llamado al sistema

	li $v0, 8 							# read string,  
    	la $a0, bufferPalabra						# $a0 = dirección del bufer de entrada (la dirección de "buffer" apuntará a las palabras)
    	li $a1, 100							# $a1 = número máximo de caracteres para leer
    	syscall
       
    	la $t1, bufferPalabra						# guardamos la dirección la dirección de memoria en el cpu, en el registro $t1	
    	add $s3, $t1, $zero						# hacemos copia de la dirección en memoria de la palabra que bsucaremos INMUTABLE
	
	lbu $t4, 0($t1)  							# cargamos la letra de la palabra a buscar
	addi $s0, $zero, 1						# filas
	addi $s1, $zero, 1						# columna

bucleFila:  
	lbu $t3, 0($t0)							# $t3, almacena el caracter leido de t0, es decir caracter de la fila de la sopa de letras
	beq $t3, 13, cambiarFila 						# si (caracter == \r, entonces debemos pasar a la fila de abajo	
	beq $t3, 10, cambiarFila 						# si (caracter == \n, entonces debemos pasar a la fila de abajo	
	beq $t3, $zero, palabraNoEncontrada 				# si (caracter == \0, entonces es que hemos recorrido toda la sopa de letras y no hallamos la palabra
	beq $t3, $t4, calcularIndiceMovimiento
	addi $t0, $t0, 1
	lbu $t3, 0($t0)
	beq $t3, 32, bucleFila
	addi $s1, $s1, 1							# aumentar columna
	j bucleFila

bucleColumna:
	sll $t5, $t3, 7
	sll $t6, $t4,1
	add $t7, $t0, $t5
	add $t8, $t7, $t6
	lbu $t9, 0($t8)
	
	addi $t4, $t4, 1
	bne $t3, $t1, bucleColumna
														# iteramos	            
cambiarFila:
 	addi $t0, $t0, 2							# aumentamos a la "otra fila", se asume que esta despues del enter
 	addi $s0, $s0, 1							# aumenta fila
 	addi $s1, $zero, 1						# reincia columna
 	j bucleFila
 	
cambiarColumna:
 	addi $t0, $t0, 1							#aumentamos al siguiente caracter de la sopa de letra	
 	j bucleFila
        
calcularIndiceMovimiento: 							# se asume que es un valor constante
 	addi $t6, $zero, 201 						# desplazamiento vertical
 	addi $t7, $zero, 2 						# desplazameinto horizontal
 	
 	add $t2, $zero, $t0						# guardar dirección de descubrimiento
 
movernos:
 	
 	jal movimientoDerecha
 	bne $s6, $zero,  terminarMovimiento						# la encontro por la derecha 	
 	jal movimientoIzquierda
 	bne $s6, $zero,  terminarMovimiento
 	jal movimientoArriba
 	bne $s6, $zero,  terminarMovimiento
 	jal movimientoAbajo
 	bne $s6, $zero,  terminarMovimiento						# las 4 rutinas de movernos (derecha, izquierda, arriba o abajo, pueden ser una dos o una sola subturina que reciba argumentos
 	
 	
 	beq $s6, $zero,  cambiarColumna
 		
 	
terminarMovimiento: 								# esta rutina salta a buscarOtraPalabra.
 	j buscarOtraPalabra	
 	
movimientoDerecha:
	addi $sp, $sp, -4 						# Reserva 2 palabras en pila (8 bytes)			
	sw $ra, 0($sp) 							# guarda ra 
	
	add $t0, $t0, $t7							# aumentamos indice para avanzar en las letras de la sopaletra
	lbu $t8, 0($t0)							# caracter siguiente de la sopaletra
	addi $t1, $t1, 1							# aumentamos indice para avanzar en el caracter de la palabra a buscar
 	lbu $t9, 0($t1)							# caracter siguiente de la palabra a buscar
 
 	jal comprobarFinal
 	lw $ra, 0($sp) 							# restaurar ra
	addi $sp, $sp, 4
 	
 	bne $s6, $zero, infoPalabra  					# hemos encontrado toda la palabra por la derecha
 	beq $t8, $t9, movimientoDerecha
 	
	add $a0, $t2, $zero						# argumento de la funcion para saber desde donde reiniciar
	j reiniciarIndice 
 			
reiniciarIndice:
 	add $t0, $a0, $zero						# reseteamos indice a la posicion de descubrimiento
 	add $t1, $s3, $zero						# reseteamos indice a la posición del primer caracter de la palabra buscada

 	jr $ra

movimientoIzquierda: 
	addi $sp, $sp, -4 						# Reserva 2 palabras en pila (8 bytes)			
	sw $ra, 0($sp) 							# guarda ra 
	
	sub $t0, $t0, $t7							# aumentamos indice para avanzar en las letras de la sopaletra
	lbu $t8, 0($t0)							# caracter siguiente de la sopaletra
	addi  $t1, $t1, 1						# aumentamos indece para avanzar en el caracter de la palabra a buscar
	lbu $t9, 0($t1)							# caracter siguiente de la palabra a buscar
 	
	jal comprobarFinal						# si ya hemos recorrido toda la palabra
	lw $ra, 0($sp) 							# restaurar ra
	addi $sp, $sp, 4
 
	bne $s6, $zero, infoPalabra  					# hemos encontrado toda la palabra por la derecha
	beq $t8, $t9, movimientoIzquierda
	addi $t0, $t0, -1   

	add $a0, $t2, $zero						# argumento de la funcion para saber desde donde reiniciar
	j reiniciarIndice
######################################################################### 
movimientoArriba:
 	addi $sp, $sp, -4 						# Reserva 2 palabras en pila (8 bytes)			
	sw $ra, 0($sp) 							# guarda ra 

	sub $t0, $t0, $t6							# aumentamos indice para avanzar en las letras de la sopaletra
 	lbu $t8, 0($t0)							# caracter siguiente de la sopaletra
 	add $t1, $t1, 1							# aumentamos indece para avanzar en el caracter de la palabra a buscar
 	lbu $t9, 0($t1)							# caracter siguiente de la palabra a buscar
 	
 	jal comprobarFinal
 	lw $ra, 0($sp) 							# restaurar ra
	addi $sp, $sp, 4
 	
 	bne $s6, $zero, infoPalabra  					# hemos encontrado toda la palabra por la derecha 	
 	beq $t8, $t9, movimientoArriba					# son diferentes es decir que no conincidieron en la letra n-sima

	add $a0, $t2, $zero						# argumento de la funcion para saber desde donde reiniciar
 	j reiniciarIndice
 	
movimientoAbajo:
 	addi $sp, $sp, -4 						# Reserva 2 palabras en pila (8 bytes)			
	sw $ra, 0($sp) 							# guarda ra 
	
	add $t0, $t0, $t6
	blt $t0, $t3, finMovimientoAbajo
	sub $t0, $t0, $t6
	addi $t0, $t0, -4900
	
	addi $t2, $t2, 1
	
	jal comprobarFinal
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	bne $s6, $zero, infoPalabra
	j reiniciarIndice


#########################################################################
				
finMovimientoAbajo:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
 
comprobarFinal:
	bne $t9, 10, noFinalPalabraBuscada					# si t9 != 10, entonces no hemos llegado al final de la palabra buscada					
	addi $s6, $zero, 1						# bandera para saber si hemos encontrado la palabra, 1 = encontrada, 0 = no encontrada					
	jr $ra								# retornar
	
infoPalabra:
 	li $v0, 4
 	la $a0, mensajeEncontrada
 	syscall
 	
 	li $v0, 4
 	la $a0, fila
 	syscall
 	
 	li $v0, 1
 	la $a0, ($s0)
 	syscall
 	
 	li $v0, 4
 	la $a0, columna
 	syscall
 	
 	li $v0, 1
 	la $a0, ($s1)
 	syscall

 	add $a0, $s2, $zero						# argumento de la funcion para saber desde donde reiniciar
 	j reiniciarIndice
     
noFinalPalabraBuscada:
	addi $s6, $zero, 0						# hacemos esto 0 dado que no hemos llegado al final
	jr $ra
                      
palabraNoEncontrada:		
	li $v0, 4
 	la $a0, mensajeNoEncontrada
 	syscall
 		
buscarOtraPalabra:	
	addi $sp, $sp, -20 					# Reserva 2 palabras en pila (8 bytes)			
	sw $s3, 0($sp) 
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t6, 16($sp)
		
	li $v0, 4						# pregunta si quiere buscar otra palabra
 	la $a0, mensajeBuscarOtra
 	syscall
 		
 	li $v0, 8 						# read string,  
    	la $a0, bufferBuscarPalabra				# $a0 = dirección del bufer de entrada (la dirección de "buffer" apuntará a las respuesta)
    	li $a1, 3						# $a1 = número máximo de caracteres para leer
    	syscall
       
    	la $t1, bufferBuscarPalabra				# guardamos la dirección la dirección de memoria en el cpu, en el registro $t1	
    	add $s3, $t1, $zero
    	lb $t6, 0($t1)

    		
    	lb $t2, opc1						# Cargo el valor de y en la variable temporal $t2
	lb $t3, opc2						# Cargo el valor de n en la variable temporal $t3
		
	beq $t6, $t2, continuarBuscando
	bne $t6, $t3, opcionInvalida
		
	li $v0, 4
 	la $a0, mensajeFinalizar
 	syscall
 		
 	j exit
 
opcionInvalida:
 	li $v0, 4						# alerta de una opción invalida
	la $a0, mensajeOpciones
	syscall
 		
 	lw $s3, 0($sp) 
    	lw $t1, 4($sp) 
    	lw $t2, 8($sp) 
    	lw $t3, 12($sp) 
    	lw $t6, 16($sp) 						# restaurar ra
	addi $sp, $sp, 20  
 		
 	j buscarOtraPalabra
				
continuarBuscando:	
    	lw $s3, 0($sp) 
    	lw $t1, 4($sp) 
    	lw $t2, 8($sp) 
    	lw $t3, 12($sp) 
    	lw $t6, 16($sp) 						# restaurar ra
	addi $sp, $sp, 20  
	add $t0, $s2, $zero
	j solicitarPalabras  			
        
exit: 	li $v0, 10							# Constante para terminar el programa
	syscall       
        
