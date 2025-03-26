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
    ; return: uint32_t
srand:

    push    r2

    ldr     r2, seed_addr ; r2 -> seed addr
    str     r0, [r2, #0] ; r0 -> low
    str     r1, [r2, #2] ; r1 -> high

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
    
    ; error -> r2
    mov     r2, #0
    ; i -> r4

    ; r1:r0 -> 5423 = 0x152F
    mov     r0, #0x2F
    movt    r0, #0x15
    mov     r1, #0x00
    movt    r1, #0x00
    bl      srand

    ; i = r4 = 0
    mov     r4, #0

for_loop:
    ; -- condition --
    ; error != 0
    mov     r5, #0
    cmp     r2, r5
    bne     for_end
    ; i >= N
    ldr     r5, n_addr
    cmp     r4, r5
    bhs     for_end
    ; -- for body --

    ; rand_number -> r0
    bl      rand

    ; rand_number == result[i]
    ldr     r5, result_addr
    ldr     r7, [r5, r4]
    cmp     r0, r7
    beq     if_end
    
    ; error = 1
    mov     r2, #1
if_end:

    ; i++
    add     r4, r4, #1
    b       for_loop

for_end:

    mov     r0, #0
    b       .    

n_addr:
    .word   N
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
