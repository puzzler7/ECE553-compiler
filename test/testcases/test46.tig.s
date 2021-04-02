L14:
addi t129, $0, 0
addi t130, $0, 1
addi t131, $0, 0
bne t129, t131, L11
beq t129, t131, L12
L12:
addi t130, $0, 0
L11:
add t130, $0, t130
j L13
L13:
