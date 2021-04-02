L12:
addi t131, $0, 0
move t103, t131
jal initArray
move t129, t101
addi t135, $0, 2
addi t136, $0, 4
mul t134, t135, t136
add t133, t129, t134
lw t132, 0(t133)
add t132, $0, t132
j L11
L11:
