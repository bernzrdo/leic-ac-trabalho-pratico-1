    .equ    STACK_SIZE, 64
    .equ    N, 5

    .text
    b       program
    b       .

program:
    ldr     sp, stack_top_addr
    b       main

stack_top_addr:
    .word   stack_top

    ; r1:r0 -> uint32_t M
    ; r3:r2 -> uint32_t m
    ; return: uint32_t
umull32:
    mov     pc, lr

    ; r1:r0 -> uint32_t nseed
srand:

    push    r2

    ldr     r2, seed_addr ; r2 -> seed addr
    str     r0, [r2, #0] ; r0 -> low
    str     r1, [r2, #2] ; r1 -> hi

    pop     r2

    mov     pc, lr

    ; return: uint16_t
rand:

    push r2
    push r3
    push r4
    push r5

    ldr     r4, seed_addr ; r4 -> seed addr
    ; r1:r0 -> seed
    ldr     r0, [r4, #0] ; r0 -> low
    ldr     r1, [r4, #2] ; r1 -> high
    
    ; r3:r2 -> 214013 = 0x343FD
    mov     r3, #0x3
    mov     r2, #0xFD
    movt    r2, #0x43
    
    bl      umull32
    ; r1:r0 -> seed * 214013

    ; r3:r2 -> 2531011 = 0x269EC3
    mov     r3, #0x26
    mov     r2, #0xC3
    movt    r2, #0x9E

    ; r1:r0 + r3:r2 = r5:r4
    add     r4, r0, r2
    adc     r5, r1, r3
    
    ; r5:r4 >> 16 = r1:r0
    mov     r1, #0x00
    mov     r0, r5 
    
    pop     r5
    pop     r4
    pop     r3
    pop     r2

    mov     pc, lr

main:       ; código aplicacional
    b       .

result_addr:
    .word   result
seed_addr:
    .word   seed

    .data   ; variáveis globais
result:
    .word   17747, 2055, 3664, 15611, 9816
seed:
    .word   0x0000, 0x0001
    
    .stack
    .space  STACK_SIZE

stack_top:
    ; linha vazia
