.word 0x100 50
	add $sp, $sp, $imm, -3			# 0: allocate space in stack.
	sw  $s0, $sp, $imm, 0			# 2: save $s0. 
	sw  $s1, $sp, $imm, 1			# 4: save $s1. 
	sw  $s2, $sp, $imm, 2			# 6: save $s2. 
	lw $s0, $zero, $imm, 0x100		# 8: Get the circle radius $s0=radius
	add $s1, $zero, $imm, 174 		# A: $s1=175-1 (x_index=x_axis_center-1)
For1:                                 
	add $s1, $s1, $imm, 1			# C: $s1++
	add $t0, $s0, $imm, 175			# E: $t0 = (x_axis_center + radius)
	bge $imm, $s1, $t0, Return		# 10: if (x_index >= x_axis_center + radius) goto Return
	add $s2, $zero, $imm, 142 		# 12: $s2=143-1 (y_index=y_axis_center-1)
For2:                                 
	add $s2, $s2, $imm, 1			# 14: $s2++
	add $t0, $s0, $imm, 143			# 16: $t0 = (y_axis_center + radius)
	bge $imm, $s2, $t0, For1		# 18: if (y_index >= y_axis_center + radius) goto For1
	sub $t0, $s1, $imm, 175			# 1A: $t0 = x_index - x_axis_center
	mul $t0, $t0, $t0, 0			# 1C: $t0 = $t0^2
	sub $t1, $s2, $imm, 143			# 1D: $t1 = y_index - y_axis_center
	mul $t1, $t1, $t1, 0			# 1F: $t1 = $t1^2
	add $t0, $t0, $t1, 0 			# 20: $t0 += $t1	
	mul $t1, $s0, $s0, 0			# 21: $t1 = radius^2
	bgt $imm, $t0, $t1, For1		# 22: if ($t0 > radius^2) goto For1 # color the pixel                 
	add $a0, $s1, $zero, 0			# 24: $a0 = x_index
	add $a1, $s2, $zero, 0			# 25: $a1 = y_index
	jal $imm, $zero, $zero, Color	# 26: call to Color
	
	sub $a1, $imm, $s2, 286			# 28: $a1 = 2*y_axis_center - y_index
	jal $imm, $zero, $zero, Color	# 2A: call to Color
	sub $a0, $imm, $s1, 350			# 2C: $a0 = 2*x_axis_center - x_index
	jal $imm, $zero, $zero, Color	# 2E: call to Color
	add $a1, $s2, $zero, 0			# 30: $a1 = y_index
	jal $imm, $zero, $zero, Color	# 31: call to Color	
	beq $imm, $zero, $zero, For2	# 33: goto For2
Return:                               
	lw $s2, $sp, $imm, 2			# 35: restore $s2
	lw $s1, $sp, $imm, 1			# 37: restore $s1
	lw $s0, $sp, $imm, 0			# 39: restore $s0
	add $sp, $sp, $imm, 3			# 3B: restore stack
	halt $zero, $zero, $zero, 0		# 3D: halt
Color: # color pixel function
	out $a0, $zero, $imm, 19		# 3E: monitor_x = x_index
	out $a1, $zero, $imm, 20		# 40: monitor_y = y_index
	add $t0, $zero, $imm, 255		# 42: $t0 = 255 (white color)
	out $t0, $zero, $imm, 21		# 44: monitor_data = 255 (white)
	add $t0, $zero, $imm, 1			# 46: $t0 = 1
	out $t0, $zero, $imm, 18		# 48: monitor_cmd = 1 (write pixel to monitor)	
	beq $ra, $zero, $zero, 0		# 4A: go back