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
    mov     pc, lr

    ; return: uint16_t
rand:
    mov     pc, lr

main:
    ; código aplicacional
    b       .

    .data
    ; variáveis globais

    .stack
    .space  STACK_SIZE

stack_top:
    ; linha vazia
