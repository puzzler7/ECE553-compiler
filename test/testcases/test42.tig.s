L35:
addi t141, $0, 0
move t103, t141
jal initArray
move t129, t101
addi t144, $0, 4
addi t145, $0, 4
mul t143, t144, t145
move t103, t143
jal malloc
move t131, t101
la t146, L18
sw t146, 0(t131)
la t147, L19
sw t147, 4(t131)
addi t148, $0, 0
sw t148, 8(t131)
addi t149, $0, 0
sw t149, 12(t131)
move t103, t131
jal initArray
move t132, t101
la t152, L21
move t103, t152
jal initArray
move t133, t101
addi t155, $0, 4
addi t156, $0, 4
mul t154, t155, t156
move t103, t154
jal malloc
move t134, t101
la t157, L24
sw t157, 0(t134)
la t158, L25
sw t158, 4(t134)
addi t159, $0, 2432
sw t159, 8(t134)
addi t160, $0, 44
sw t160, 12(t134)
move t135, t134
addi t163, $0, 2
addi t164, $0, 4
mul t162, t163, t164
move t103, t162
jal malloc
move t136, t101
la t165, L27
sw t165, 0(t136)
addi t139, t136, 4
addi t167, $0, 1900
move t103, t167
jal initArray
move t138, t101
