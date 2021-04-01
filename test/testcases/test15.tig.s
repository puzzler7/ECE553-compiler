L16:
addi t130, $0, 20
addi t131, $0, 1
beq t130, t131, t 
 bne t130, t131, f 
L12:
addi t132, $0, 3
move t129, t132
j lab
L13:
addi t133, $0, 0
move t129, t133
j lab
add t129, $0, t129
j lab
L15:
