L15:
addi t129, $0, 0
addi t130, $0, 1
addi t131, $0, 0
bne t129, t131, L12
beq t129, t131, L13
L13:
addi t130, $0, 0
L12:
add t130, $0, t130
j L14
L14:
