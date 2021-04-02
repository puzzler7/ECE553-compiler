L16:
addi t130, $0, 5
addi t131, $0, 4
bgt t130, t131, L12
ble t130, t131, L13
L12:
addi t129, $0, 13
j L14
L13:
la t132, L11
move t129, t132
j L14
L14:
add t129, $0, t129
j L15
L15:
