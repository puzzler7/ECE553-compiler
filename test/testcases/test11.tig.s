L22:
addi t130, $0, 10
addi t132, $0, 0
add t132, $0, t132
L20:
addi t133, $0, 0
addi t134, $0, 1
beq t133, t134, L19
bne t133, t134, L17
L19:
addi t130, t130, 1
j L20
L17:
j L21
L21:
