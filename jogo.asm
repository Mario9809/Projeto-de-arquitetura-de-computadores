ORG 00H

MOV 30H, #00H ; índice da sequência gerada
MOV 31H, #00H ; índice da jogada do usuário
MOV 32H, #00H ; contador de acertos
MOV 33H, #00H ; erro detectado (0 = não, 1 = sim)
MOV 34H, #01H ; nível inicial (1)

MOV P1, #00H  ; zera os LEDs
MOV P2, #00H  ; zera o display LCD
MOV P3, #0FH  ; configura o teclado

ACALL lcd_init
ACALL lcd_clear
MOV DPTR, #msg_boas_vindas
ACALL lcd_display_msg
ACALL delay_long

gerar_sequencia:
    MOV A, 34H
    MOV B, A
    ADD A, #2  ; nível 1 → 3 LEDs, nível 2 → 4 LEDs, etc.
    MOV 35H, A ; quantidade de LEDs deste nível

MOV R0, #40H ; endereço base para salvar a sequência
MOV R1, #00H

acender_leds:
    MOV A, R1
    MOV P1, A  ; Acende o LED com índice R1 (0, 1, 2, ...)
    ACALL delay_curto
    MOV P1, #00H

    MOV @R0, A  ; Armazena a posição do LED aceso
    INC R0
    INC R1

    MOV A, R1
    MOV B, 35H
    CJNE A, B, acender_leds

MOV 31H, #00H  ; zera índice do jogador
MOV 32H, #00H  ; zera contador de acertos
MOV R0, #40H   ; ponteiro da sequência

leitura_teclado:
    ACALL ler_tecla
    MOV A, 31H
    MOV R1, A
    MOV A, tecla_lida  ; valor pressionado
    MOV B, @R0          ; valor da sequência esperada
    CJNE A, B, erro

    INC R0
    INC 31H
    INC 32H

    MOV A, 32H
    MOV B, 35H
    CJNE A, B, leitura_teclado

ACALL lcd_clear
MOV DPTR, #msg_proximo_nivel
ACALL lcd_display_msg
ACALL delay_long

INC 34H
MOV A, 34H
CJNE A, #06, gerar_sequencia


erro:
MOV 33H, #01H
ACALL lcd_clear
MOV DPTR, #msg_fim
ACALL lcd_display_msg
SJMP $


vitoria:
ACALL lcd_clear
MOV DPTR, #msg_vitoria
ACALL lcd_display_msg
SJMP $

; Função de leitura do teclado 4x3
ler_tecla:
    ; Função para ler a tecla pressionada no teclado 4x3
    ; Configura as colunas para alta impedância (não ativa nenhuma coluna por enquanto)
    MOV P3, #0F0H   ; Colunas P3.0 a P3.2 serão usadas como saída, e as linhas como entrada (P3.4 a P3.7)
    
    ; Varre as colunas do teclado para detectar a tecla pressionada
    MOV R0, #00H      ; Inicializa R0 com 0, ele será usado para verificar a coluna
    MOV R1, #01H      ; Inicializa R1 para os valores das linhas (Linhas 1, 2, 3)
    
varre_colunas:
    ; Limpa todos os bits das colunas
    MOV P3, #0F0H    ; Reseta o valor das colunas
    ; Ativa a coluna correspondente
    MOV A, R0
    MOV P3, A        ; P3.0 a P3.2 são as colunas, P3.4 a P3.7 são as linhas

    ; Verifica as 4 linhas para ver se alguma linha foi pressionada
    MOV A, P3        ; Lê o valor das linhas (P3.4 a P3.7)
    ANL A, #0F0H     ; Mascara para pegar apenas as linhas (P3.4 a P3.7)

    ; Se alguma linha for detectada, a tecla foi pressionada
    CJNE A, #0F0H, tecla_detectada

    ; Se não detectou, passa para a próxima coluna
    INC R0           ; Avança para a próxima coluna
    MOV A, R0
    CJNE A, #03, varre_colunas ; Se não terminou de varrer as 3 colunas, vai para a próxima coluna

    RET               ; Se nenhuma tecla for pressionada, retorna

tecla_detectada:
    ; Identifica qual tecla foi pressionada
    MOV A, R1         ; R1 guarda a linha da tecla pressionada
    MOV B, R0         ; R0 guarda a coluna da tecla pressionada

    ; Agora, R1 (linha) e R0 (coluna) têm os valores correspondentes
    ; Usamos esses valores para mapear a tecla pressionada

    ; O mapeamento das teclas:
    ; Linha 1: 1, 2, 3
    ; Linha 2: 4, 5, 6
    ; Linha 3: 7, 8, 9
    ; Linha 4: *, 0, #

    ; Verifica a linha e a coluna e mapeia a tecla
    MOV A, R1
    MOV B, R0
    ; Se a linha for 1
    CJNE A, #01, linha_2
    ; Se a coluna for 0
    CJNE B, #00, linha_1_coluna_2
    MOV tecla_lida, #01H   ; Tecla 1
    RET

linha_1_coluna_2:
    CJNE B, #01, linha_1_coluna_3
    MOV tecla_lida, #02H   ; Tecla 2
    RET

linha_1_coluna_3:
    CJNE B, #02, linha_1_coluna_4
    MOV tecla_lida, #03H   ; Tecla 3
    RET

linha_1_coluna_4:
    CJNE B, #03, linha_2
    MOV tecla_lida, #0AH   ; Tecla * (asterisco)
    RET

linha_2:
    CJNE A, #02, linha_3
    ; Verifica as colunas para linha 2
    CJNE B, #00, linha_2_coluna_2
    MOV tecla_lida, #04H   ; Tecla 4
    RET

linha_2_coluna_2:
    CJNE B, #01, linha_2_coluna_3
    MOV tecla_lida, #05H   ; Tecla 5
    RET

linha_2_coluna_3:
    CJNE B, #02, linha_2_coluna_4
    MOV tecla_lida, #06H   ; Tecla 6
    RET

linha_2_coluna_4:
    CJNE B, #03, linha_3
    MOV tecla_lida, #0BH   ; Tecla # (jogo da velha)
    RET

linha_3:
    CJNE A, #03, linha_4
    ; Verifica as colunas para linha 3
    CJNE B, #00, linha_3_coluna_2
    MOV tecla_lida, #07H   ; Tecla 7
    RET

linha_3_coluna_2:
    CJNE B, #01, linha_3_coluna_3
    MOV tecla_lida, #08H   ; Tecla 8
    RET

linha_3_coluna_3:
    CJNE B, #02, linha_3_coluna_4
    MOV tecla_lida, #09H   ; Tecla 9
    RET

linha_3_coluna_4:
    CJNE B, #03, linha_4
    MOV tecla_lida, #0CH   ; Tecla 0
    RET

linha_4:
    ; Linha 4 - Asterisco ou Jogo da velha
    CJNE A, #04, fim
    CJNE B, #00, fim
    MOV tecla_lida, #0EH  ; Tecla *
    RET

fim:
    RET

msg_boas_vindas: DB 'MEMORIZE A SEQUENCIA', 0
msg_proximo_nivel: DB 'PROXIMO NIVEL!', 0
msg_fim: DB 'FIM DE JOGO!', 0
msg_vitoria: DB 'VOCE VENCEU!', 0

