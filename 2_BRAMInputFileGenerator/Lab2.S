
# Lab02测试使用
# LUI
# AUIPC
# ADDI
# SLTI
# SLTIU
# XORI
# ORI
# ANDI
# SLLI
# SRLI
# SRAI
# ADD
# SUB
# SLL
# SLT
# SLTU
# XOR
# SRL
# SRA
# OR
# AND



.org 0x0
 	.global _start
_start:
    LUI t0, 0x12345 # t0 = 0x12345000
    NOP
    NOP
    NOP
    NOP
    AUIPC t1, 0x20000 # t1 = 0x20000000 + pc
    NOP
    NOP
    NOP
    NOP
    XOR t2, t2, t2 # t2 = 0
    NOP
    NOP
    NOP
    NOP
    ADDI t2, t2, 2 # t2 = 2
    NOP
    NOP
    NOP
    NOP
    SLTI t3, t2, -1 # t3 = 0
    NOP
    NOP
    NOP
    NOP
    SLTIU t4, t2, -1 # t4 = 1
    NOP
    NOP
    NOP
    NOP
    XORI t5, t2, 2 # t5 = 0
    NOP
    NOP
    NOP
    NOP
    ORI t3, t2, 1 # t3 = 3
    NOP
    NOP
    NOP
    NOP
    ANDI t3, t2, 1 # t3 = 0
    NOP
    NOP
    NOP
    NOP
    SLLI t3, t2, 1 # t3 = 4
    NOP
    NOP
    NOP
    NOP
    SRLI t3, t2, 1 # t3 = 1
    NOP
    NOP
    NOP
    NOP
    XOR t0, t0, t0 # t0 = 0
    NOP
    NOP
    NOP
    NOP
    ADDI t0, t0, -2 # t0 = -2
    NOP
    NOP
    NOP
    NOP
    SRAI t3, t0, 1 # t3 = -1
    NOP
    NOP
    NOP
    NOP
    ADD t4, t3, t2 # t4 = t3 + t2 = 1
    NOP
    NOP
    NOP
    NOP
    SUB t4, t2, t3 # t4 = t2 - t3 = 3
    NOP
    NOP
    NOP
    NOP
    SLL t4, t2, t3 # t4 = t2 << 1 = 4
    NOP
    NOP
    NOP
    NOP
    SLT t4, t2, t0 # t4 = 0
    NOP
    NOP
    NOP
    NOP
    SLTU t4, t2, t0 # t4 = 1
    NOP
    NOP
    NOP
    NOP
    SRL t3, t2, t4 # t3 = 1
    NOP
    NOP
    NOP
    NOP
    SRA t3, t0, t4 # t3 = -1
    NOP
    NOP
    NOP
    NOP
    OR t3, t0, t4 # t3 = -2
    NOP
    NOP
    NOP
    NOP
    AND t3, t0, t4 # t3 = 1

