L12:
addi t133, $0, 2
addi t134, $0, 4
mul t132, t133, t134
move t103, t132
jal malloc
move t129, t101
addi t135, $0, 0
sw t135, 0(t129)
addi t136, $0, 0
sw t136, 4(t129)
move t130, t129
add t130, $0, t130
j L11
L11:
