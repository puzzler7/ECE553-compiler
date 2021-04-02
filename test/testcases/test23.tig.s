L17:
addi t133, $0, 2
addi t134, $0, 4
mul t132, t133, t134
move t103, t132
jal malloc
move t129, t101
la t135, L13
sw t135, 0(t129)
addi t136, $0, 0
sw t136, 4(t129)
move t130, t129
addi t139, $0, 1
addi t140, $0, 4
mul t138, t139, t140
add t137, t130, t138
la t141, L15
