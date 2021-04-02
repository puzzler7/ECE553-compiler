L19:
addi t132, $0, 0
addi t133, $0, 0
sw t133, 92(t132)
addi t134, $0, 0
add t134, $0, t134
addi t130, $0, 0
addi t135, $0, 0
add t135, $0, t135
L17:
addi t136, $0, 100
ble t130, t136, L16
bgt t130, t136, L15
L16:
addi t130, t130, 1
j L17
L15:
j L18
L18:
