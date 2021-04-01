L21:
L19:
addi t132, $0, 0
addi t133, $0, 0
beq t132, t133, t 
 bne t132, t133, f 
L16:
addi t134, $0, 1
move t131, t134
j lab
L17:
addi t136, $0, 0
addi t137, $0, 0
mul t135, t136, t137
move t131, t135
j lab
move t101, t131
jr t128
addi t138, $0, 0
add t138, $0, t138
j lab
L20:
