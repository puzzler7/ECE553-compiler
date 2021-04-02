L17:
addi t130, $0, 5
addi t131, $0, 4
bgt t130, t131, L13
ble t130, t131, L14
L13:
addi t129, $0, 13
j L15
L14:
la t132, L12
move t129, t132
j L15
L15:
add t129, $0, t129
j L16
L16:
