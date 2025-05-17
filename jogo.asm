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
CJNE NIVEL, #6, PROXIMO_NIVEL  ; Se esse não atingiu o nível de 6, vai para o parte do código próximo nível

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
    INC R0 ;isso para ir percorrendo a sequência acendo o led de acordo com o número da vez
    DJNZ R1, MOSTRAR_LOOP  ; Sempre vai decrementar 1 no valor que está no R1, que é o número do contador que é o número de leds da sequência, enquanto não zerar a função se repete.
    RET













