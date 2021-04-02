L16:
L11:
addi t132, $0, 0
beq t130, t132, L12
bne t130, t132, L13
L12:
addi t131, $0, 1
j L14
L13:
subi t135, t130, 1
move t103, t135
jal L11
move t133 t101
mul t131, t130, t133
j L14
L14:
move t101, t131
jr t128
addi t136, $0, 0
add t136, $0, t136
addi t138, $0, 10
move t103, t138
jal L11
j L15
L15:
