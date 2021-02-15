.word 0x100 50
	sub $sp, $sp, $imm, 3			#  allocate 3 spaces at stack.
	sw  $s0, $sp, $imm, 0			#  save $s0. 
	sw  $s1, $sp, $imm, 1			#  save $s1. 
	sw  $s2, $sp, $imm, 2			#  save $s2. 
	lw $s0, $zero, $imm, 0x100		#  $s0 = radius of the circle
	add $s1, $zero, $imm, 174 		#  $s1=175-1 (x_index=x_center-1)
For1:                                 
	add $s1, $s1, $imm, 1			#  $s1++
	add $t0, $s0, $imm, 175			#  $t0 = (x_axis_center + radius)
	bge $imm, $s1, $t0, Return		#  if (x_index >= x_center + radius) -> Return
	add $s2, $zero, $imm, 142 		#  $s2=143-1 (y_index=y_center-1)
For2:                                 
	add $s2, $s2, $imm, 1			# $s2++
	add $t0, $s0, $imm, 143			# $t0 = (y_axis_center + radius)
	bge $imm, $s2, $t0, For1		# if (y_index >= y_center + radius) -> For1
	sub $t0, $s1, $imm, 175			# $t0 = x_index - x_center
	mul $t0, $t0, $t0, 0			# $t0 = $t0^2
	sub $t1, $s2, $imm, 143			# $t1 = y_index - y_center
	mul $t1, $t1, $t1, 0			# $t1 = $t1^2
	add $t0, $t0, $t1, 0 			# $t0 += $t1	
	mul $t1, $s0, $s0, 0			# $t1 = radius^2
	bgt $imm, $t0, $t1, For1		# if ($t0 > radius^2) -> For1 # color the pixel                 
	add $a0, $s1, $zero, 0			# $a0 = x_index
	add $a1, $s2, $zero, 0			# $a1 = y_index
	jal $imm, $zero, $zero, Color	# call to Color
	
	sub $a1, $imm, $s2, 286			# $a1 = 2*y_center - y_index
	jal $imm, $zero, $zero, Color	# call to Color
	sub $a0, $imm, $s1, 350			# $a0 = 2*x_center - x_index
	jal $imm, $zero, $zero, Color	# call to Color
	add $a1, $s2, $zero, 0			# $a1 = y_index
	jal $imm, $zero, $zero, Color	# call to Color	
	beq $imm, $zero, $zero, For2	# -> For2
Return:      
	lw $s0, $sp, $imm, 0			# restore $s0
	lw $s1, $sp, $imm, 1			# restore $s1
	lw $s2, $sp, $imm, 2			# restore $s2
	add $sp, $sp, $imm, 3			# restore 3 places to stack
	halt $zero, $zero, $zero, 0		# halt

Color: 
	add $t0, $zero, $imm, 255		# $t0 = 255 (white )
	out $t0, $zero, $imm, 21		# monitor_data = 255 (white)
	out $a0, $zero, $imm, 19		# monitor_x = x_index
	out $a1, $zero, $imm, 20		# monitor_y = y_index
	add $t0, $zero, $imm, 1			# $t0 = 1
	out $t0, $zero, $imm, 18		# monitor_cmd = 1 (write pixel to monitor)	
	beq $ra, $zero, $zero, 0		# return with $ra