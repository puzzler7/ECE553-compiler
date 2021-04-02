L16:
addi t130, $0, 10
addi t131, $0, 20
bgt t130, t131, L12
ble t130, t131, L13
L12:
addi t129, $0, 30
j L14
L13:
addi t129, $0, 40
j L14
L14:
add t129, $0, t129
j L15
L15:
