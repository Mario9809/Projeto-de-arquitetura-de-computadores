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


; --- REPRODUZIR_SEQUENCIA ---
REPRODUZIR_SEQUENCIA:
    MOV R0, #SEQUENCIA   ; ponteiro da sequência
    MOV R1, CONTADOR     ; quantidade de teclas a ler
    MOV ACERTOS, #0      ; zera acertos

LER_PROXIMA_TECLA:
    CALL LER_TECLA       ; tecla lida em TECLA
    CJNE TECLA, #0FFH, TECLA_LIDA ; se tecla válida, compara
    SJMP LER_PROXIMA_TECLA ; se nenhuma tecla, continua esperando

TECLA_LIDA:
    MOV A, TECLA
    MOV R2, @R0          ; pega o valor da sequência no índice atual
    CJNE A, R2, PERDEU   ; se não for igual, perdeu

    INC ACERTOS
    INC R0
    DJNZ R1, LER_PROXIMA_TECLA

    RET


; --- LER_TECLA ---
; Lê teclado matricial 4 linhas x 3 colunas no P3
; Retorna tecla no endereço TECLA (0 a 11) ou 0xFF se nenhuma tecla
; Mapeamento de teclas:
; 0=1,1=2,2=3,3=4,4=5,5=6,6=7,7=8,8=9,9=10=*,10=0,11=#

LER_TECLA:
    MOV TECLA, #0FFH    ; Nenhuma tecla pressionada inicialmente

    ; Coluna 0 ativa (bit 0 = 0)
    MOV P3, #0F7H       ; 1111 0111
    CALL LER_LINHA_COLUNA
    CJNE A, #0FFH, RETORNA_TECLA

    ; Coluna 1 ativa (bit 1 = 0)
    MOV P3, #0FBH       ; 1111 1011
    CALL LER_LINHA_COLUNA
    CJNE A, #0FFH, AJUSTA_COLUNA_1

    ; Coluna 2 ativa (bit 2 = 0)
    MOV P3, #0FDH       ; 1111 1101
    CALL LER_LINHA_COLUNA
    CJNE A, #0FFH, AJUSTA_COLUNA_2

    SJMP RETORNA_TECLA

AJUSTA_COLUNA_1:
    ADD A, #3           ; offset coluna 1 = +3 teclas
    SJMP RETORNA_TECLA

AJUSTA_COLUNA_2:
    ADD A, #6           ; offset coluna 2 = +6 teclas

RETORNA_TECLA:
    MOV TECLA, A
    RET


; --- LER_LINHA_COLUNA ---
; Supondo P3 bits 4 a 7 representam linhas
; Se linha pressionada bit fica 0 (ativo baixo)
; Retorna no acumulador A o número da linha (0 a 3) ou 0xFF se nenhuma

LER_LINHA_COLUNA:
    MOV A, P3
    ANL A, #0F0H      ; máscara para linhas (bits 4 a 7)
    CPL A             ; inverte bits para facilitar
    SWAP A            ; troca nibble alto com baixo
    ANL A, #0FH       ; pega apenas bits baixos (0 a 0x0F)
    
    ; Agora bits 0 a 3 indicam qual linha está pressionada
    ; Checa linha 0
    CJNE A, #01H, CHECA_LINHA_1
    MOV A, #0
    RET

CHECA_LINHA_1:
    CJNE A, #02H, CHECA_LINHA_2
    MOV A, #1
    RET

CHECA_LINHA_2:
    CJNE A, #04H, CHECA_LINHA_3
    MOV A, #2
    RET

CHECA_LINHA_3:
    CJNE A, #08H, LINHA_NAO_ENCONTRADA
    MOV A, #3
    RET

LINHA_NAO_ENCONTRADA:
    MOV A, #0FFH
    RET


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




















