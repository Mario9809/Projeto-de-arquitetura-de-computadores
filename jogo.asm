ORG 00H ;Definição do local de memória onde se inicia o programa
LJMP INICIO ;Salto direto para o local do código onde se inicia a lógica do jogo


;Parte do código onde se usa o EQU para colocar nomes nos endereços de memória para usá-los como se fossem variáveis
NIVEL     EQU 30H   ; Nível atual (1-5)
SEQUENCIA EQU 40H   ; Armazena a sequência (40H-4FH)
TECLA     EQU 50H   ; Tecla pressionada
CONTADOR  EQU 51H   ; Contador de LEDs
ACERTOS   EQU 52H   ; Contador de acertos

ORG 100H 
INICIO:
MOV P1, #0FFH    ; Desliga todos os LEDs
MOV P3, #0FFH   ; Configura teclado
MOV NIVEL, #1   ; Nível inicial


;Lógica para todas vez que se entra em um nível inicial ou niveis acima
NOVO_NIVEL: ;Label para marcar o local onde essa lógica acontece
MOV A, NIVEL ;Move o valor do nivel para o acumulador
MOV P1, A ;Move o valor do nivel que stá no acumulador para a porta P1, para então acender o LED correspondente ao número do nível
CALL DELAY_500MS ;Delay para manter o LED ligado
MOV P1, #00H ;Desliga o led
CALL DELAY_500MS

MOV A, NIVEL
ADD A, #2 ;Adiciona 2 ao nível. Isso define o tamanho da sequência que será gerada (nível 1 = 3 LEDs, nível 2 = 4 e por ai em diante)
MOV CONTADOR, A ;Move o valor do número dea sequência para a variável contador


;Linhas que irão chamar funções para o funcionamento do jogo em sí
CALL GERAR_SEQUENCIA
CALL MOSTRAR_SEQUENCIA
CALL REPRODUZIR_SEQUENCIA

MOV A, ACERTOS ; Carrega no acumulador quantos acertos o jogador teve.
CJNE A, CONTADOR, PERDEU ; Compara o valor dos acertos com a quantidade da sequência, se forem diferentes o jogador perde, então salta a função PERDEU

;Caso não tenha ido para PERDEU, continua a percorrer o código indo para essa linha:
INC NIVEL ;Incrementa 1 para o nível
MOV A, NIVEL
CJNE A, #6, PROXIMO_NIVEL


;Se atingiu número 6 o código continua, e vai para essa parte
CALL PISCAR_LEDS ;Vai para uma função que pisca os leds como sinal de vitória
JMP INICIO        ; Salta diretamente para o inicio do jogo

PROXIMO_NIVEL:
MOV P1, NIVEL
CALL DELAY_500MS
MOV P1, #00H
CALL DELAY_500MS
JMP NOVO_NIVEL


PERDEU:
MOV P1, #0AAH    ; Pisca padrão 10101010, esse é sinal visual para indicar derrota
CALL DELAY_1S
MOV P1, #55H     ; Pisca padrão 01010101, esse é sinal visual para indicar derrota
CALL DELAY_1S
JMP INICIO       ; Como o jogador perdeu, irá Reiniciar o jogo


GERAR_SEQUENCIA:
    MOV ACERTOS, #0        ; Zera contador de acertos
    MOV R0, #SEQUENCIA     ; Ponteiro para onde salvar a sequência
    MOV R1, CONTADOR       ; Quantidade de números da sequência
    MOV A, #0              ; Começa a sequência do 0

GERAR_LOOP:
    MOV @R0, A             ; Salva o número atual no vetor
    INC A                  ; Próximo número da sequência
    INC R0                 ; Próxima posição no vetor
    DJNZ R1, GERAR_LOOP    ; decrementa a quantidade de numeros da sequencia até zerar, enquanto não zerar repete
    RET


MOSTRAR_SEQUENCIA:
    MOV R0, #SEQUENCIA     ; Começa no início do vetor
    MOV R1, CONTADOR       ; Quantos números mostrar

MOSTRAR_LOOP:
    MOV A, @R0             ; Pega número da sequência
    ACALL ACENDER_LED      ; Acende o LED correspondente
    CALL DELAY_500MS       ; Espera um pouco
    MOV P1, #0FFH          ; Apaga todos os LEDs
    CALL DELAY_200MS       ; Espera de novo
    INC R0                 ; isso para ir percorrendo a sequência acendo o led de acordo com o número da vez
    DJNZ R1, MOSTRAR_LOOP  ; Sempre vai decrementar 1 no valor que está no R1, que é o número do contador que é o número de leds da sequência, enquanto não zerar a função se repete.
    RET


;Aqui acendemos os LEDs para isso usamos outros registradores, somente para acender os LEDs e saber quando parar
ACENDER_LED:
    ; Espera-se que o número do LED esteja no registrador A (0 a 7)

    MOV R2, #01H   ; Começa com o bit 00000001
    MOV A, R2
RL A
MOV R2, A
MOV R3, A      ; Copia o número do LED para R3

SHIFT_LOOP:
    CJNE R3, #0, SHIFT    ; Se R3 não for 0, continua deslocando
    SJMP FIM_ACENDER_LED

SHIFT:
   MOV A, R2
RL A
MOV R2, A

    DEC R3      ; Decrementa o contador
    SJMP SHIFT_LOOP

FIM_ACENDER_LED:
   MOV P1, #0FFH   ; Apaga todos os LEDs (P1 é ativo em 0)
   MOV P1, #0FFH   ; Apaga todos os LEDs (P1 é ativo em 0)

    MOV P1, R2  ; Acende o LED correspondente
    RET


LER_TECLA:
    CLR A
    MOV TECLA, #0FFH  ; Inicializa com valor inválido

    MOV DPTR, #TABELA_TECLAS

    MOV R2, #00H       ; R2 = índice da linha (0 a 3)

LER_LINHA:
    MOV A, #0FFH
    CPL A
    RL A
    RL A
    RL A
    RL A               ; A = 11110000 (desativa uma linha por vez)
    ORL A, R2          ; Ativa apenas a linha atual
    MOV P3, A

    NOP                ; Pequeno delay de estabilização
    NOP

    MOV A, P3
    ANL A, #0F0H       ; Isola os bits das colunas

    CJNE A, #0F0H, COLUNA_DETECTADA

    INC R2
    CJNE R2, #04, LER_LINHA

    ; Nenhuma tecla pressionada
    SJMP LER_TECLA     ; Fica esperando até alguma tecla ser pressionada

COLUNA_DETECTADA:
    ; Descobre qual coluna foi pressionada
    MOV R3, #00H       ; Coluna = 0
    MOV R4, #10H       ; Começa do bit 4 (P3.4)

VERIFICAR_COLUNA:
    MOV A, P3
    ANL A, R4
    JZ TECLA_ENCONTRADA
    MOV A, R4
RL A
MOV R4, A

    INC R3
    CJNE R3, #04, VERIFICAR_COLUNA

    SJMP LER_TECLA   ; Coluna inválida

TECLA_ENCONTRADA:
    ; Calcula índice da tecla: linha * 4 + coluna
    MOV A, R2
    RL A
    RL A              ; A = linha * 4
    ADD A, R3         ; A = A + coluna
    MOVC A, @A+DPTR   ; A = TABELA_TECLAS[A]
    MOV TECLA, A
    RET


REPRODUZIR_SEQUENCIA:
    MOV R0, #SEQUENCIA   ; Ponteiro para sequência
    MOV R1, CONTADOR     ; Número de teclas a ler
    MOV ACERTOS, #0

LER_TECLAS_LOOP:
    CALL LER_TECLA       ; Aguarda e lê uma tecla
    MOV A, TECLA
    CJNE A, #0FFH, VERIFICAR

    SJMP LER_TECLAS_LOOP ; Se tecla inválida, continua tentando

VERIFICAR:
    MOV A, TECLA
    MOV B, @R0            ; Pega valor da sequência esperada
    CJNE A, B, FIM_REPRODUZIR

    INC ACERTOS
    INC R0
    DJNZ R1, LER_TECLAS_LOOP

FIM_REPRODUZIR:
    RET

TABELA_TECLAS:
    DB 1, 2, 3, 0FFH
    DB 4, 5, 6, 0FFH
    DB 7, 8, 9, 0FFH
    DB 0, 0FFH, 0FFH, 0FFH

PISCAR_LEDS:
    MOV R5, #6             ; Número de piscadas

PISCAR_LOOP:
    MOV P1, #0FFH          ; Apaga todos LEDs (assumindo ativo em 0)
    ACALL DELAY_250MS
    MOV P1, #00H           ; Acende todos LEDs
    ACALL DELAY_250MS
    DJNZ R5, PISCAR_LOOP

    RET


DELAY_250MS:
    MOV R4, #3
DELAY_250MS_LOOP1:
    MOV R3, #250
DELAY_250MS_LOOP2:
    MOV R2, #250
DELAY_250MS_LOOP3:
    DJNZ R2, DELAY_250MS_LOOP3
    DJNZ R3, DELAY_250MS_LOOP2
    DJNZ R4, DELAY_250MS_LOOP1
    RET



DELAY_1S:
    ACALL DELAY_250MS
    ACALL DELAY_250MS
    ACALL DELAY_250MS
    ACALL DELAY_250MS
    RET


DELAY_2S:
    ACALL DELAY_1S
    ACALL DELAY_1S
    RET


DELAY_5S:
    ACALL DELAY_1S
    ACALL DELAY_1S
    ACALL DELAY_1S
    ACALL DELAY_1S
    ACALL DELAY_1S
    RET

DELAY_500MS:
    ACALL DELAY_250MS
    ACALL DELAY_250MS
    RET


DELAY_200MS:
    MOV R4, #2
DELAY_200MS_LOOP1:
    MOV R3, #250
DELAY_200MS_LOOP2:
    MOV R2, #200
DELAY_200MS_LOOP3:
    DJNZ R2, DELAY_200MS_LOOP3
    DJNZ R3, DELAY_200MS_LOOP2
    DJNZ R4, DELAY_200MS_LOOP1
    RET




















