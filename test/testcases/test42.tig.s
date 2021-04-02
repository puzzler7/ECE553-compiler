L34:
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
la t146, L17
sw t146, 0(t131)
la t147, L18
sw t147, 4(t131)
addi t148, $0, 0
sw t148, 8(t131)
addi t149, $0, 0
sw t149, 12(t131)
move t103, t131
jal initArray
move t132, t101
la t152, L20
move t103, t152
jal initArray
move t133, t101
addi t155, $0, 4
addi t156, $0, 4
mul t154, t155, t156
move t103, t154
jal malloc
move t134, t101
la t157, L23
sw t157, 0(t134)
la t158, L24
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
la t165, L26
sw t165, 0(t136)
addi t139, t136, 4
addi t167, $0, 1900
move t103, t167
jal initArray
move t138, t101
sw t138, 0(t139)
move t137, t136
addi t171, $0, 1
addi t172, $0, 4
mul t170, t171, t172
add t169, t137, t170
addi t174, $0, 2
addi t175, $0, 4
mul t173, t174, t175
add t168, t169, t173
addi t176, $0, 2323
sw t176, 0(t168)
j L33
L33:
