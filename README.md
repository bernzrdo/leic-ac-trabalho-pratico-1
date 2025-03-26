# Trabalho de Avaliação #1

```c
#define N 5

// array de resultados esperados
uint16_t result[N] = { 17747, 2055, 3664, 15611, 9816 };
// seed global
uint32_t seed = 1;

// multiplica dois uint32_t
uint32_t umull32(uint32_t M, uint32_t m){

    int64_t M_ext = M;
    int64_t p = m;
    uint8_t p_1 = 0;

    // ir por cada bit
    for(uint16_t i = 0; i < 32; i++){

        if((p & 0x1) == 0 && p_1 == 1){
            p += M_ext << 32;
        }else if((p & 0x1) == 1 && p_1 == 0){
            p -= M_ext << 32;
        }

        p_1 = p & 0x1;
    	p >>= 1;

    }

    return p;
}

uint32_t umull32Melhorado(uint32_t M, uint32_t m){

    int64_t p = m;
    uint8_t lastBit = 0;

    // acho que isto é a mesma merda mas kinda mais facil

    // ir por cada bit
    for(uint16_t i = 0; i < 32; i++){

        uint8_t currBit = p & 0x1

        if(currBit == 0 && lastBit == 1){
            p += M << 32;
        }else if(currBit == 1 && lastBit == 0){
            p -= M << 32;
        }

        lastBit = currBit;
    	p >>= 1;

    }

    return p;
}

// modifica a variável global
void srand(uint32_t nseed){
    seed = nseed;
}

uint16_t rand(void){
    // atualizar seed
    // ((seed * 214013) + 2531011) % RAND_MAX
    // RAND_MAX é o maior valor possível de uint32_t
    seed = (umull32(seed, 214013) + 2531011) % RAND_MAX;
    return (seed >> 16);
}

int main(void){

    uint8_t error = 0; // flag de nº inesperado
    uint16_t rand_number;
    uint16_t i;

    // inicializar seed
    srand(5423);

    // verificar números random
    // para se houver um nº inesperado
    for(i = 0; error == 0 && i < N; i++){

        // obter nº aleatório
        rand_number = rand();

        // verificar se é inesperado
        if(rand_number != result[i]){
            error = 1;
        }

    }

    return 0;
}
```
