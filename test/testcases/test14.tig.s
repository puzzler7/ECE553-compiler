L17:
addi t135, $0, 2
addi t136, $0, 4
mul t134, t135, t136
move t103, t134
jal malloc
move t129, t101
la t137, L12
sw t137, 0(t129)
addi t138, $0, 0
sw t138, 4(t129)
move t130, t129
addi t140, $0, 0
move t103, t140
jal initArray
move t131, t101
addi t141, $0, 0
addi t142, $0, 1
beq t141, t142, L13
bne t141, t142, L14
L13:
addi t132, $0, 3
j L15
L14:
addi t132, $0, 4
j L15
L15:
add t132, $0, t132
j L16
L16:
