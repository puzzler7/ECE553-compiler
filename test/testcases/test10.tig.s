L16:
L14:
addi t129, $0, 10
addi t130, $0, 5
bgt t129, t130, L13
ble t129, t130, L12
L13:
addi t132, $0, 5
addi t131, t132, 6
add t131, $0, t131
j L14
L12:
j L15
L15:
