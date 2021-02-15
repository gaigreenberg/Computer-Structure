		add $s2, $zero, $imm, 128        # sector size is 128
		add $s0, $zero, $imm, 1          # flag = 1
		add $s1, $zero, $imm, 0          # $s1 = 0 (j = 0)   
		add $t0, $zero, $imm, 1          # hwReg[1] = irq1enable
		out $imm, $zero, $t0, 1          # irq1enable = 1
read1:
		add $t0, $zero, $imm, 16         # hwReg[16] = diskbuffer
		out $imm, $t0, $zero, 0          # disk buffer= 0x0
		add $t0, $zero, $imm, 15         # hwReg[15] = disk sector
		out $imm, $t0, $zero, 0          # disk sector = 0
		add $t1, $zero, $imm, 1          # set diskcmd = 1 (read)
		add $s1, $s1, $imm, 1            # j += 1
		in $t0, $zero, $imm, 17          # $t0 = disk status
		bne $imm, $t0, $zero, wait       # if diskstatus != 0 (disk is busy) -> wait
		beq $imm, $zero, $zero, diskop   # if disk is free -> diskop
read2:
		add $t0, $zero, $imm, 16         # hwReg[16] = diskbuffer
		out $imm, $t0, $zero, 512        # disk buffer= 0x200
		add $t0, $zero, $imm, 15         # hwReg[15] = disk sector
		out $imm, $t0, $zero, 1          # disk sector = 1
		add $t1, $zero, $imm, 1          # cmd = 1 (read)
		add $s1, $s1, $imm, 1            # j += 1
		in $t0, $zero, $imm, 17          # $t0 = disk status
		bne $imm, $t0, $zero, wait       # if diskstatus != 0 (disk is busy) -> wait
		beq $imm, $zero, $zero, diskop   # if disk is free -> diskop
read3:
		add $t0, $zero, $imm, 16         # hwReg[16] = diskbuffer
		out $imm, $t0, $zero, 1024       # disk buffer= 0x400
		add $t0, $zero, $imm, 15         # hwReg[15] = disk sector
		out $imm, $t0, $zero, 2          # disk sector = 2
		add $t1, $zero, $imm, 1          # cmd = 1 (read)
		add $s1, $s1, $imm, 1            # j += 1
		in $t0, $zero, $imm, 17          # $t0 = disk status
		bne $imm, $t0, $zero, wait       # if diskstatus != 0 (disk is busy) -> wait
		beq $imm, $zero, $zero, diskop   # if disk is free -> diskop
read4:
		add $t0, $zero, $imm, 16         # hwReg[16] = diskbuffer
		out $imm, $t0, $zero, 1536        # disk buffer= 0x600
		add $t0, $zero, $imm, 15         # hwReg[15] = disk sector
		out $imm, $t0, $zero, 3          # disk sector = 3
		add $t1, $zero, $imm, 1          # cmd = 1 (read)
		add $s1, $s1, $imm, 1            # j += 1
		in $t0, $zero, $imm, 17          # $t0 = disk status
		bne $imm, $t0, $zero, wait       # if diskstatus != 0 (disk is busy) -> wait
		beq $imm, $zero, $zero, diskop   # if disk is free -> diskop
calcxor:
		add $s0, $zero, $zero, 0         # flag = 0 ( ignore irq1)
		add $t0, $zero, $zero, 0         # i = 0
xorloop:
		beq $imm, $t0, $s2, done         # if (i == 128) -> done
		lw $t2, $t0, $imm, 0             # $t2 =  i'th word sector 1 
		lw $t3, $t0, $imm, 512           # $t3 =  i'th word sector 2
		xor $t2, $t2, $t3, 0             # $t2 = ($t2) xor ($t3)
		lw $t3, $t0, $imm, 1024          # $t3 =  i'th word sector 3
		xor $t2, $t2, $t3, 0             # $t2 = ($t2) xor ($t3) - kind of recursive xor 
		lw $t3, $t0, $imm, 1536          # $t3 =  i'th word sector 4
		xor $t2, $t2, $t3, 0             # $t2 = ($t2) xor ($t3) - kind of recursive xor 
		sw $t2, $t0, $imm, 2048          # save xor result from all forth xor's
		add $t0, $t0, $imm, 1            # i += 1
		beq $imm, $zero, $zero, xorloop  # xor loop on sector size
done:
		add $t0, $zero, $imm, 16         # hwReg[16] = diskbuffer
		out $imm, $zero, $t0, 2048       # disk buffer = 2048
		add $t0, $zero, $imm, 15         # hwReg[15] = disk sector
		out $imm, $zero, $t0, 4          # disk sector = 4
		add $t1, $zero, $imm, 2          # cmd = 2 (write)
		add $s1, $s1, $imm, 1            # j += 1
		add $s0, $zero, $imm, 1          # flag = 1
		in $t0, $zero, $imm, 17          # $t0 = disk status
		bne $imm, $t0, $zero, wait       # if diskstatus != 0 (disk is busy) -> wait
		beq $imm, $zero, $zero, diskop   # if disk is free -> diskop
wait:
		add $t0, $zero, $imm, 6          # the number of irq handler
		out $imm, $zero, $t0, irq_op     # set the pc of irq hendler to diskop
loop:
		beq $imm, $zero, $zero, loop     # infinite loop
irq_op:
		beq $imm, $s0, $zero, regularret # if flag == 0 return from regular ret
		add $t0, $zero, $imm, 14         # $t0 = hwReg[14] = diskcmd
		out $t1, $zero, $t0, 0           # disk cmd =  $t1 before  wait
		add $t1, $zero, $imm, 1          # temp = 1
		beq $imm, $s1, $t1, return2      # if j == 1 return from irq to read2
		add $t1, $zero, $imm, 2          # temp = 2
		beq $imm, $s1, $t1, return3      # if j == 2 return from irq to read3
		add $t1, $zero, $imm, 3          # temp = 3
		beq $imm, $s1, $t1, return4      # if j == 3 return from irq to read4
		add $t1, $zero, $imm, 4          # temp = 4
		beq $imm, $s1, $t1, return5      # if j == 4 return from irq to calcxor
		add $t1, $zero, $imm, 5          # temp = 5
		beq $imm, $s1, $t1, exit         # if j == 5 return from irq to exit
diskop:
		add $t0, $zero, $imm, 14         # $t0 = hwReg[14] = diskcmd
		out $t1, $zero, $t0, 0           # disk cmd =  $t1 before the call
		add $t1, $zero, $imm, 1          # temp = 1
		beq $imm, $s1, $t1, read2        # if j == 1 return from irq to read2
		add $t1, $zero, $imm, 2          # temp = 2
		beq $imm, $s1, $t1, read3        # if j == 2 return from irq to read3
		add $t1, $zero, $imm, 3          # temp = 3
		beq $imm, $s1, $t1, read4        # if j == 3 return from irq to read4
		add $t1, $zero, $imm, 4          # temp = 4
		beq $imm, $s1, $t1, calcxor      # if j == 4 return from irq to calcxor
		add $t1, $zero, $imm, 5          # temp = 5
		beq $imm, $s1, $t1, exit         # if j == 5 return from irq to exit
return2:
		add $t0, $zero, $imm, 7          # hwReg[7] = irqreturn
		out $imm, $zero, $t0, read2      
		reti $zero, $zero, $zero, 0      # return from irq1
return3:
		add $t0, $zero, $imm, 7          # hwReg[7] = irqreturn
		out $imm, $zero, $t0, read3      
		reti $zero, $zero, $zero, 0      # return from irq1
return4:
		add $t0, $zero, $imm, 7          # hwReg[7] = irqreturn
		out $imm, $zero, $t0, read4      
		reti $zero, $zero, $zero, 0      # return from irq1
return5:
		add $t0, $zero, $imm, 7          # hwReg[7] = irqreturn
		out $imm, $zero, $t0, calcxor      
		reti $zero, $zero, $zero, 0      # return from irq1
regularret:
		reti $zero, $zero, $zero, 0      # return from irq1 
exit:
		halt $zero, $zero, $zero, 0