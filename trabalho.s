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

    push    r4
    push    r5
    push    r6
    push    r7
    push    r8
    push    r9
    push    r10

    ; i -> r6 = 0
    mov     r6, #0

    /*
    r0 -> M low
    r1 -> M high
    p -> r3:r2:r5:r4
    i -> r6
    last bit (p_1) -> r7
    r8 -> current bit
    */

    ; p -> r2:r3:r4:r5 
    
    mov     r4,r3
    mov     r5,r2
    mov     r3,#0
    mov     r2,#0

    ; mais significativos
    ; mov     r2, r2
    ; mov     r3, r3

    ; last bit (p_1) -> r7
    mov     r7, #0

umull32_for:
    ; -- condition --
    ; i >= 32
    mov     r9, #32
    cmp     r6, r9
    bhs     umull32_for_end
    ; -- body --
    
    ; current bit -> r8
    mov     r9, #1
    and     r8, r5, r9

    mov     r10,r6 ; valor de i em r10
    mov     r6,r8  ; valor de current bit no r6(i)

umull32_if1:

    ; current bit != 0
    mov     r9, #0
    cmp     r6, r9
    bne     umull32_if2
    
    ; lastBit != 1
    mov     r9, #1
    cmp     r7, r9
    bne     umull32_if2
    
    ; p += M << 32
    add     r3,r3,r0
    adc     r2,r2,r1

    b       umull32_if_end
    
umull32_if2:

    ; current bit != 1
    mov     r9, #1
    cmp     r6, r9
    bne     umull32_if_end

    ; lastBit != 0
    mov     r9, #0
    cmp     r7, r9
    bne     umull32_if_end

    ; p -= M << 32;
    sub     r3,r3,r0 
    sbc     r2,r2,r1  
    
umull32_if_end:

    mov     r8,r6 ; valor de current bit volta para a var original
    mov     r6,r10  ; valor de i volta para var original

    ; last bit = current bit
    mov     r7, r8

    ; p >>= 1
    ; p -> r2:r3:r4:r5 -> NOVO

    asr     r2,r2,#1
    rrx     r3,r3
    rrx     r4,r4
    rrx     r5,r5

    ; -- increment --
    add     r6, r6, #1
    b       umull32_for

umull32_for_end:

    ; p -> r2:r3:r4:r5 -> NOVO
    ; return p
    mov     r0,r5
    mov     r1,r4
    
    pop     r4
    pop     r5
    pop     r6
    pop     r7
    pop     r8
    pop     r9
    pop     r10

    mov     pc, lr

    ; r1:r0 -> uint32_t nseed
    ; return: uint32_t
    
srand:

    push    r2

    ldr     r2, seed_addr ; r2 -> seed addr
    str     r0, [r2, #0] 
    str     r1, [r2, #2] 

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
    
    push    lr
    bl      umull32
    pop     lr
    ; r1:r0 -> seed * 214013

    ; r3:r2 -> 2531011 = 0x269EC3
    mov     r3, #0x26
    mov     r2, #0xC3
    movt    r2, #0x9E

    ; r1:r0 + r3:r2 = r5:r4
    add     r4, r0, r2
    adc     r5, r1, r3

    ; adicionar seed
    ldr     r3, seed_addr ; r3 -> seed addr
    str     r4, [r3, #0] ; low
    str     r5, [r3, #2] ; high
    
    
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

    ; variavel para aceder a result[i]
    mov     r3, #0

    ; r1:r0 -> 5423 = 0x152F
    mov     r0, #0x2F
    movt    r0, #0x15
    mov     r1, #0x00
    movt    r1, #0x00
    bl      srand

    ; i -> r4 = 0
    mov     r4, #0

main_for:
    ; -- condition --
    ; error != 0
    mov     r5, #0
    cmp     r2, r5
    bne     main_for_end
    ; i >= N
    ldr     r5, n_addr
    cmp     r4, r5
    bhs     main_for_end
    ; -- body --

    ; rand_number -> r0
    bl      rand

    ; rand_number == result[i]
    ldr     r5, result_addr
    add     r3, r4, r4 ; multiplica r3 por 2 para aceder ap result na posicao i
    ldr     r7, [r5, r3]
    cmp     r0, r7
    beq     main_if_end
    
    ; error = 1
    mov     r2, #1
main_if_end:

    ; -- increment --
    add     r4, r4, #1
    b       main_for

main_for_end:

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
    ;.word  17747, 2055, 3664, 48379, 9816 array certo para nao dar erro
seed:
    .word   0x0001, 0x0000
    
    .stack  
    .space  STACK_SIZE

stack_top:
    ; linha vazia
