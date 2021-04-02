L15:
addi t130, $0, 10
addi t131, $0, 20
bgt t130, t131, L11
ble t130, t131, L12
L11:
addi t129, $0, 30
j L13
L12:
addi t129, $0, 40
j L13
L13:
add t129, $0, t129
j L14
L14:
