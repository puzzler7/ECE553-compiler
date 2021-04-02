L18:
addi t132, $0, 0
sw t132, 92(t127)
addi t133, $0, 0
add t133, $0, t133
addi t130, $0, 0
addi t134, $0, 0
add t134, $0, t134
L16:
addi t135, $0, 100
ble t130, t135, L15
bgt t130, t135, L14
L15:
addi t130, t130, 1
j L16
L14:
j L17
L17:
