ORG 00H
LJMP INICIO                ; Salta para a rotina de inicialização em 100H

; Endereços de variáveis globais na RAM interna
NIVEL     EQU 30H           ; Armazena o nível atual do jogo
SEQUENCIA EQU 40H           ; Início da memória para a sequência de teclas
TECLA     EQU 50H           ; Armazena a tecla lida
CONTADOR  EQU 51H           ; Quantidade de teclas a serem lidas/exibidas
ACERTOS   EQU 52H           ; Contador de acertos do jogador

ORG 100H
INICIO:
    MOV P3, #0FFH           ; Configura P3 como entrada (leitura do teclado)
    MOV NIVEL, #1           ; Inicia no nível 1

NOVO_NIVEL:
    MOV A, NIVEL
    MOV P1, A               ; Exibe o nível atual nos LEDs (P1)
    CALL DELAY_500MS
    MOV P1, #0FFH           ; Apaga os LEDs
    CALL DELAY_500MS

    MOV A, NIVEL
    ADD A, #2
    MOV CONTADOR, A         ; Define o número de teclas com base no nível

    CALL GERAR_SEQUENCIA    ; Gera nova sequência pseudoaleatória
    CALL MOSTRAR_SEQUENCIA  ; Mostra a sequência ao jogador
    CALL REPRODUZIR_SEQUENCIA ; Lê a sequência digitada pelo jogador

    MOV A, ACERTOS
    CJNE A, CONTADOR, PERDEU ; Se não acertou tudo, vai para PERDEU

    INC NIVEL               ; Passa para próximo nível
    MOV A, NIVEL
    CJNE A, #6, PROXIMO_NIVEL ; Se não chegou no nível 6, repete

    CALL PISCAR_LEDS        ; Se chegou ao fim, pisca LEDs (vitória)
    JMP INICIO              ; Reinicia o jogo

PROXIMO_NIVEL:
    MOV P1, NIVEL           ; Exibe novo nível
    CALL DELAY_500MS
    MOV P1, #00H
    CALL DELAY_500MS
    JMP NOVO_NIVEL

PERDEU:
    MOV P1, #0AAH           ; Padrão de falha
    CALL DELAY_1S
    MOV P1, #55H
    CALL DELAY_1S
    JMP INICIO              ; Reinicia o jogo

; Gera uma sequência simples: 0,1,2,... (sem aleatoriedade real)
GERAR_SEQUENCIA:
    MOV ACERTOS, #0         ; Zera acertos
    MOV R0, #SEQUENCIA
    MOV R1, CONTADOR
    MOV A, #0

GERAR_LOOP:
    MOV @R0, A              ; Guarda valor em SEQUENCIA
    INC A
    INC R0
    DJNZ R1, GERAR_LOOP
    RET

; Mostra a sequência nos LEDs
MOSTRAR_SEQUENCIA:
    MOV R0, #SEQUENCIA
    MOV R1, CONTADOR

MOSTRAR_LOOP:
    MOV A, @R0              ; Carrega valor
    ACALL ACENDER_LED       ; Acende LED correspondente
    CALL DELAY_500MS
    MOV P1, #0FFH           ; Apaga LEDs
    CALL DELAY_200MS
    INC R0
    DJNZ R1, MOSTRAR_LOOP
    RET

ACENDER_LED:
    MOV R2, #01H
    MOV R3, A               ; A tem o índice do LED
SHIFT_LOOP:
    CJNE R3, #0, SHIFT      ; Faz deslocamentos para posicionar LED
    SJMP FIM_ACENDER_LED
SHIFT:
    MOV A, R2
    RL A
    MOV R2, A
    DEC R3
    SJMP SHIFT_LOOP
FIM_ACENDER_LED:
    MOV P1, #0FFH
    MOV P1, R2              ; Exibe LED
    RET

; Lê e compara a sequência digitada
REPRODUZIR_SEQUENCIA:
    MOV R0, #SEQUENCIA
    MOV R1, CONTADOR
    MOV ACERTOS, #0

LER_PROXIMA_TECLA:
    CALL LER_TECLA
    MOV A, TECLA
    CJNE A, #0FFH, TECLA_LIDA
    SJMP LER_PROXIMA_TECLA

TECLA_LIDA:
    MOV A, @R0               ; Lê sequência da RAM
    MOV B, A
    MOV A, TECLA
    CJNE A, B, PERDEU
    INC ACERTOS
    INC R0
    DJNZ R1, LER_PROXIMA_TECLA
    RET


; Leitura do teclado matricial
LER_TECLA:
    MOV TECLA, #0FFH
    MOV P3, #0F7H ;Ativa a coluna 0
    CALL LER_LINHA_COLUNA
    CJNE A, #0FFH, RETORNA_TECLA
    MOV P3, #0FBH
    CALL LER_LINHA_COLUNA
    CJNE A, #0FFH, AJUSTA_COLUNA_1
    MOV P3, #0FDH
    CALL LER_LINHA_COLUNA
    CJNE A, #0FFH, AJUSTA_COLUNA_2
    SJMP RETORNA_TECLA
AJUSTA_COLUNA_1:
    ADD A, #3
    SJMP RETORNA_TECLA
AJUSTA_COLUNA_2:
    ADD A, #6
RETORNA_TECLA:
    MOV TECLA, A
    RET

; Detecta qual linha do teclado foi pressionada
LER_LINHA_COLUNA:
    MOV A, P3
    ANL A, #0F0H
    CPL A
    SWAP A
    ANL A, #0FH
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

; Pisca todos os LEDs para indicar vitória
PISCAR_LEDS:
    MOV R5, #6
PISCAR_LOOP:
    MOV P1, #0FFH
    ACALL DELAY_250MS
    MOV P1, #00H
    ACALL DELAY_250MS
    DJNZ R5, PISCAR_LOOP
    RET

; Delays
DELAY_250MS:
    MOV R4, #1
DELAY_250MS_LOOP1:
    MOV R3, #1
DELAY_250MS_LOOP2:
    MOV R2, #1
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
    MOV R4, #1
DELAY_200MS_LOOP1:
    MOV R3, #1
DELAY_200MS_LOOP2:
    MOV R2, #1
DELAY_200MS_LOOP3:
    DJNZ R2, DELAY_200MS_LOOP3
    DJNZ R3, DELAY_200MS_LOOP2
    DJNZ R4, DELAY_200MS_LOOP1
    RET
