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

## Perguntas

1. Considere a definição da função `umull32` que realiza a multiplicação de dois números naturais codificados com 32 bits, em que o parâmetro `M` corresponde ao multiplicando e o parâmetro `m` ao multiplicador.

    **a)** Implemente a função `umull32`.

    **b)** Indique, em número de bytes, a quantidade de memória de código ocupada por essa implementação. Justifique a sua resposta.

    > Cada instrução é codificada em 16 bits. A nossa implementação do `umull32` contém 56 instruções ou seja ocupa 896 bits que é 112 bytes.

2. Considere a definição da função `srand` que afeta a variável global `seed` com o valor de uma nova semente.

    **a)** Implemente a definição da variável `seed`, definindo as secções necessárias. Justifique a sua resposta.

    > Para definir a variável global `seed` de 32 bits, na secção `.data`(pois a secção `.data` é destinada a variáveis globais iniciadas ou não) colocamos a label `seed` e implementamos a diretiva `.word 0x0001, 0x0000`. A razão para implementar essas duas words (16 bits cada) é devido à `seed` necessitar de 32 bits no qual, a primeira word representa a parte baixa da variável seed e a segunda a parte alta.
    > Depois colocamos a label `seed_addr` na secção `.text` para que o código tenha acesso ao endereço da `seed`.

    **b)** Implemente a função `srand`.

3. Considere a definição da função `rand` que implementa um gerador congruencial linear (do Inglês Linear Congruential Generator – LCG) para gerar números pseudo-aleatórios entre zero e `RAND_MAX`. A constante `RAND_MAX` corresponde ao maior valor possível de codificar numa variável com tipo `uint32_t`.

    **a)** Indique duas possibilidades de implementação da constante `RAND_MAX` e discuta as suas vantagens e desvantagens quanto aos requisitos de memória.

    > A implementação usada no nosso código é que o CPU simplesmente descarta qualquer overflow além de uint32_t devido à variável ser de 32 bits assim, o CPU na verdade, não precisa executar RAND_MAX porque a variável seed já está limitada a 32 bits. A vantagem é que o calculo é inteiramente feito em registos, sem usar a memória e como a operação é redundante o próprio compilador elimina a operação. A outra implementação seria usar 2 registos com o máximo valor possível de uint32_t(0xFFFF 0xFFFF) e comparar com se a seed seria maior. O problema desta implementação é que é usado no mínimo 2 registo para fazer uma operação redundante.

    **b)** Implemente a função `rand`.

4. Relativamente à definição da função `main`, indique, justificando, o registo que é preferível utilizar para implementar a variável error: `R0` ou `R5`.

    > É preferível usar a variável error no `R5` pois, se usássemos o `R0` iria interferir na passagem de argumentos ao chamar uma função ou no retorno de uma.

5. Implemente o programa apresentado na Listagem 1 usando a linguagem assembly do P16 e as implementações propostas nos exercícios 1, 2 e 3.
