L16:
addi t132, $0, 0
move t129, t132
initArray:
addi t135, $0, 3
move $a0, t135
addi t137, $0, 0
move $a1, t137
jalr t133
 move t130, $v0
addi t138, $0, 0
addi t139, $0, 1
beq t138, t139, t 
 bne t138, t139, f 
L12:
addi t140, $0, 3
move t131, t140
j lab
L13:
addi t141, $0, 4
move t131, t141
j lab
add t131, $0, t131
j lab
L15:
