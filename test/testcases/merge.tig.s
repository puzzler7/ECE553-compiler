L117:
addi t160, t127, 92
jal L2
move t159, t101
sw t159, 0(t160)
L11:
addi t167, $0, 0
sw t167, 88(t127)
addi t168, $0, 0
add t168, $0, t168
L12:
lw t172, 0(t127)
lw t171, 92(t172)
move t103, t171
jal L3
move t169 t101
la t175, L38
move t103, t175
jal L3
move t173 t101
bge t169, t173, L49
blt t169, t173, L50
L49:
addi t133, $0, 1
lw t178, 0(t127)
lw t177, 92(t178)
move t103, t177
jal L3
move t161, t101
move t163, t161
la t180, L44
move t103, t180
jal L3
move t162, t101
ble t163, t162, L47
bgt t163, t162, L48
L48:
addi t133, $0, 0
L47:
move t134, t133
j L51
L50:
addi t134, $0, 0
j L51
L51:
move t101, t134
jr t128
lw t181, 88(t127)
move t101, t181
jr t128
L63:
addi t184, $0, 1
addi t185, $0, 4
mul t183, t184, t185
move t103, t183
jal malloc
move t152, t101
addi t186, $0, 0
sw t186, 0(t152)
move t153, t152
addi t187, $0, 0
add t187, $0, t187
move t103, t153
jal L11
move t154, t101
addi t192, $0, 0
addi t193, $0, 4
mul t191, t192, t193
add t190, t153, t191
lw t189, 0(t190)
addi t194, $0, 1
beq t189, t194, L113
bne t189, t194, L114
L113:
addi t197, $0, 2
addi t198, $0, 4
mul t196, t197, t198
move t103, t196
jal malloc
move t155, t101
sw t154, 0(t155)
addi t165, t155, 4
jal L63
move t164, t101
sw t164, 0(t165)
move t156, t155
j L115
L114:
addi t156, $0, 0
j L115
L115:
move t101, t156
jr t128
jal L63
move t157, t101
jal L63
move t158, t101
move t103, t157
move t104, t158
jal L64
move t166, t101
move t103, t166
jal L66
j L116
L116:
