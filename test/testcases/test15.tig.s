L15:
addi t130, $0, 20
addi t131, $0, 1
beq t130, t131, L11
bne t130, t131, L12
L11:
addi t129, $0, 3
j L13
L12:
addi t129, $0, 0
j L13
L13:
add t129, $0, t129
j L14
L14:
