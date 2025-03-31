#include <stdio.h>
#include <stdint.h>
#define N 5

// uint16_t result[N] = { 17747, 2055, 3664, 15611, 9816 };
uint16_t result[N] = { 17747, 2055, 3664, 48379, 9816 };
uint32_t seed = 1;

// multiplica dois uint32_t
uint32_t umull32(uint32_t M, uint32_t m){

    // printf("\n%d * %d =\n", M, m);

    int64_t M_ext = M;
    // printf("  M_ext << 32 = %d\n", M_ext << 32);
    int64_t p = m;
    uint8_t p_1 = 0;

    // ir por cada bit
    for(uint16_t i = 0; i < 32; i++){
        // printf("  for i %d:\n", i);

        // printf("    (p & 0x1) = %d\n", (p & 0x1));
        // printf("    p_1 = %d\n", p_1);

        if((p & 0x1) == 0 && p_1 == 1){
            p += M_ext << 32;
            // printf("    p += M_ext << 32\n");
        }else if((p & 0x1) == 1 && p_1 == 0){
            p -= M_ext << 32;
            // printf("    p -= M_ext << 32\n");
        }
        // printf("    p = %d\n", p);
        
        p_1 = p & 0x1;
    	p >>= 1;
        // printf("    p >> 1 = %d\n", p);
        
    }

    // printf("%d * %d = %d\n", M, m, p);
    return p;
}


// modifica a variável global
void srand(uint32_t nseed){
    seed = nseed;
}

uint16_t rand(void){
    seed = (umull32(seed, 214013) + 2531011);
    return (seed >> 16);
}

int main(void){

    uint8_t error = 0;
    uint16_t rand_number;
    uint16_t i;

    srand(5423);

    for(i = 0; error == 0 && i < N; i++){

        rand_number = rand();

        // if(rand_number != result[i]){
        //     printf("Número inesperado: i=%d rand_number=%d expected=%d\n", i, rand_number, result[i]);
        //     error = 1;
        // }else{
            printf("i=%d rand_number=%d\n", i, rand_number);
        // }

    }

    return 0;
}