L16:
addi t130, $0, 20
addi t131, $0, 1
beq t130, t131, L12
bne t130, t131, L13
L12:
addi t129, $0, 3
j L14
L13:
addi t129, $0, 0
j L14
L14:
add t129, $0, t129
j L15
L15:
