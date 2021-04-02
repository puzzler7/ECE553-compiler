L17:
L12:
addi t132, $0, 0
beq t130, t132, L13
bne t130, t132, L14
L13:
addi t131, $0, 1
j L15
L14:
subi t135, t130, 1
move t103, t135
jal L12
move t133 t101
mul t131, t130, t133
j L15
L15:
move t101, t131
jr t128
addi t136, $0, 0
add t136, $0, t136
addi t138, $0, 10
move t103, t138
jal L12
j L16
L16:
