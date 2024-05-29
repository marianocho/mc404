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
    mv s11, a1

    addi s11, s11, 3 # primeira linha
    
    li t0, 32 # t0 = ' '
    li t1, 48 # char - t1 -> int
    li t6, 10 # t6 = '\n'

    li s6, 0
    li s5, 0
    li s4, 0
    jal dimensions # ler dimensao m
    mv s0, s6 # s0 = m
    mv a0, s0 # a0 = s0 = m

    li s6, 0
    li s5, 0
    li s4, 0
    jal dimensions # ler dimensao n
    mv s1, s6 # s1 = n
    mv a1, s1 # a1 = s1 = n

    jal setCanvasSize

    mul s2, a0, a1 # s2 = m x n
    jal skipa # skippa o valor de alfa (que sempre usaremos 255)
    li t5, 255 # alfa = t5
    li t4, 0 # contador

    jal loop_pixels # ler os pixels
    
    lw ra, 0(sp)
    addi sp, sp, 4
    ret

skipa:
    lbu t2, 0(s11) # t2 = armazena o digito alfa[0]
    addi s11, s11, 1 # avanca um caractere

    lbu t2, 0(s11) # t2 = armazena o digito alfa[1]
    beq t0, t2, end_s # se t2 = ' ' -> end_s
    beq t6, t2, end_s # se t2 = '\n' -> end_s
    addi s11, s11, 1 # avanca um caractere

    lbu t2, 0(s11) # t2 = armazena o digito alfa[2]
    beq t0, t2, end_s # se t2 = ' ' -> end_s
    beq t6, t2, end_s # se t2 = '\n' -> end_s
    addi s11, s11, 2 # avanca dois caracteres
    ret

    end_s:
        addi s11, s11, 1 # avanca um caractere
        ret

loop_pixels:
    addi sp, sp, -4
    sw ra, 0(sp)
    loop_p:
        beq s2, t4, end_pix # m x n = contador
        lbu s3, 0(s11) # s3 = pixel

        slli a2, s3, 24 # a2[31...24] = pixel
        slli s10, s3, 16 # a2[23...16] = pixel
        add a2, a2, s10
        slli s10, s3, 8 # a2[15...8] = pixel
        add a2, a2, s10
        add a2, a2, t5 # a2[7...0] = alfa
        
        jal setPixel
        
        addi s11, s11, 1 # avanca um caractere
        addi t4, t4, 1 # contador++
        
        j loop_p

    end_pix:
        lw ra, 0(sp)
        addi sp, sp, 4
        ret

setPixel:
    rem a0, t4, s1 # x
    div a1, t4, s1 # y
    li a7, 2200
    ecall
    ret

setCanvasSize:
    li a7, 2201
    ecall
    ret

dimensions:
    lbu t2, 0(s11) # t2 = armazena numero[0]

    sub t2, t2, t1 # char - t1 = int = t2
    add s6, s6, t2 # s6 = t2 first digit
    addi s11, s11, 1 # avanca um caractere

    lbu t2, 0(s11) # t2 = armazena numero[1]
    beq t0, t2, end_single # se t2 = ' ' -> end_d
    beq t6, t2, end_single # se t2 = '\n' -> end_d

    sub t2, t2, t1 # char - t1 = int = t2
    mv s5, t2 # t5 = segundo digito
    addi s11, s11, 1 # avanca um caractere
    
    lbu t2, 0(s11) # t2 = armazena numero[2]
    beq t0, t2, end_double # se t2 = ' ' -> end_d
    beq t6, t2, end_double # se t2 = '\n' -> end_d

    sub t2, t2, t1 # char - t1 = int = t2
    mv s4, t2 # terceiro digito
    li t3, 100
    mul s6, s6, t3 # centena
    li t3, 10
    mul s5, s5, t3 # dezena
    add s6, s6, s5 # centena + dezena
    add s6, s6, s4 # centena + dezena + unidade

    addi s11, s11, 2 # avanca dois caracteres

    ret

    end_single:
        addi s11, s11, 1 # avanca um caractere
        ret # retornar para main

    end_double:
        li t3, 10
        mul s6, s6, t3 # dezena
        add s6, s6, s5 # unidade
        addi s11, s11, 1 # avanca um caractere
        ret


read:
    la a1, input_img   # buffer
    li a2, 262159
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

