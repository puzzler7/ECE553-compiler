L15:
L13:
addi t129, $0, 10
addi t130, $0, 5
bgt t129, t130, L12
ble t129, t130, L11
L12:
addi t132, $0, 5
addi t131, t132, 6
add t131, $0, t131
j L13
L11:
j L14
L14:
