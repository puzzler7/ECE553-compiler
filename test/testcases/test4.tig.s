L18:
L16:
addi t131, $0, 0
beq t129, t131, L13
bne t129, t131, L14
L13:
addi t132, $0, 1
move t130, t132
j L15
L14:
L12:
addi t138, $0, 1
sub t137, t129, t138
move t103, t137
jalr t135
mul t133, t129, t134
move t130, t133
j L15
L15:
move t101, t130
jr t128
addi t139, $0, 0
add t139, $0, t139
addi t141, $0, 10
move t103, t141
jal L12
j L17
L17:
