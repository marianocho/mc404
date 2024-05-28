.globl _start

_start:
    jal main
    li a0, 0
    li a7, 93 # exit
    ecall

main:
    addi sp, sp, -4
    sw ra, 0(sp)

    jal open
    jal read

    addi a1, a1, 3 # primeira linha
    
    li t0, 32 # t0 = ' '
    li t1, 48 # char - t1 -> int
    li t6, 10 # t6 = '\n'

    li s6, 0
    jal dimensions # ler dimensao m
    mv s0, s6 # s0 = m

    li s6, 0
    jal dimensions # ler dimensao n
    mv s1, s6 # s1 = n

    jal setCanvasSize

    mul s2, s0, s1 # s2 = m x n
    addi a1, a1, 4 # pula o valor de alfa que é sempre 255 e o '\n'
    li t5, 255 # alfa = t5
    li t4, 1 # contador

    jal loop_pixels # ler os pixels
    
    lw ra, 0(sp)
    addi sp, sp, 4
    ret

loop_pixels:
    beq s2, t4, end_pix # m x n = contador
    lbu s3, 0(a1) # s3 = pixel
    sb t5, 0(a2) # a2[7...0] = alfa
    sb s3, 1(a2) # a2[15...8] = pixel
    sb s3, 2(a2) # a2[23...16] = pixel
    sb s3, 3(a2) # a2[31...24] = pixel
    li a7, 2200
    ecall
    addi a1, a1, 1 # avanca um caractere
    addi t4, t4, 1 # contador++
    j loop_pixels

end_pix:
    ret

setCanvasSize:
    mv a0, s0 # largura
    mv a1, s1 # altura
    li a7, 2201
    ecall
    ret

dimensions:
    lbu t2, 0(a1) # t2 = armazena um digito lido

    beq t0, t2, end_d # se t2 = ' ' -> end_d
    beq t6, t2, end_d # se t2 = '\n' -> end_d
    sub t2, t2, t1 # char - t1 = int = t2

    add s6, s6, t2 # s6 += t2
    addi a1, a1, 1 # avanca um caractere
    j dimensions

    end_d:
        addi a1, a1, 1 # avanca um caractere
        ret # retornar para main

read:
    la a1, input_img   # buffer
    li a7, 63          # syscall read (63)
    ecall
    ret

open:
    la a0, input_file    # address for the file path
    li a1, 0             # flags (0: rdonly, 1: wronly, 2: rdwr)
    li a2, 0             # mode
    li a7, 1024          # syscall open 
    ecall
    ret

.bss

input_img: .skip 0x4000F # buffer com os valores dos pixels

.data

input_file: .asciz "image.pgm" # onde está a imagem

