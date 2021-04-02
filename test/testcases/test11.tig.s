L23:
addi t130, $0, 10
addi t132, $0, 0
add t132, $0, t132
L21:
addi t133, $0, 0
addi t134, $0, 1
beq t133, t134, L20
bne t133, t134, L18
L20:
addi t130, t130, 1
j L21
L18:
j L22
L22:
