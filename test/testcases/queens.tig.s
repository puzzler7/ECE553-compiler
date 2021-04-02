L62:
addi t153, $0, 8
sw t153, 92(t127)
addi t154, $0, 0
add t154, $0, t154
addi t146, t127, 88
lw t156, 92(t127)
move t103, t156
addi t158, $0, 0
move t104, t158
jal initArray
move t145, t101
sw t145, 0(t146)
addi t148, t127, 84
lw t160, 92(t127)
move t103, t160
addi t162, $0, 0
move t104, t162
jal initArray
move t147, t101
sw t147, 0(t148)
addi t150, t127, 80
lw t166, 92(t127)
lw t167, 92(t127)
add t165, t166, t167
subi t164, t165, 1
move t103, t164
addi t169, $0, 0
move t104, t169
jal initArray
move t149, t101
sw t149, 0(t150)
addi t152, t127, 76
lw t173, 92(t127)
lw t174, 92(t127)
add t172, t173, t174
subi t171, t172, 1
move t103, t171
addi t176, $0, 0
move t104, t176
jal initArray
move t151, t101
sw t151, 0(t152)
L11:
la t178, L60
move t103, t178
jal L0
move t101, t101
jr t128
addi t180, $0, 0
move t103, t180
jal L12
j L61
L61:
