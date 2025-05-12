ORG 00H              ; Início do programa

MOV 30H, #00H        ; indice_seq = 0 (índice da sequência gerada)
MOV 31H, #00H        ; indice_jogador = 0 (índice da sequência digitada)
MOV 32H, #00H        ; contador_acertos = 0 (contador de acertos)
MOV 33H, #00H        ; erro_detectado = 0 (0 = sem erro, 1 = erro ocorreu)
MOV 34H, #01H        ; nivel = 1 (nível inicial)


MOV P1, #00H         ; Porta P1 (LEDs) – Inicializa LEDs apagados
MOV P2, #00H         ; Porta P2 (LCD) – Inicializa LCD apagado
MOV P3, #0FH         ; Porta P3 (Keypad 4x3) – Colunas em P3.0 a P3.2, Linhas em P3.4 a P3.7

ACALL lcd_init
ACALL lcd_clear
MOV DPTR, #msg_boas_vindas  ; Exibe a mensagem de boas-vindas
ACALL lcd_display_msg
ACALL delay_long           ; Mantém a mensagem por 2 segundos

gerar_sequencia:
    MOV A, 34H             ; Carrega o nível atual
    MOV B, A               ; Usa o nível como base para a quantidade de LEDs a acender (número de LEDs por nível)

MOV R0, #00H           ; R0 irá armazenar a sequência (como LED aceso)
MOV R1, #00H           ; R1 será o índice dos LEDs a acender


acender_leds:
    MOV A, R1              ; Carrega o índice do LED
    MOV P1, A              ; Acende o LED correspondente
    ACALL delay_curto      ; Aguarda um pequeno intervalo
    MOV P1, #00H           ; Apaga o LED
    INC R1                 ; Avança para o próximo LED
    MOV A, R1
    CMP A, B               ; Compara o número de LEDs acesos com o nível
    JNZ acender_leds       ; Repete enquanto o número de LEDs não atingir o valor do nível

    ; Agora, temos que comparar a sequência gerada com o que foi digitado
    MOV R1, #00H           ; Limpa o índice de comparação
    MOV 31H, #00H          ; Limpa o índice da sequência digitada pelo jogador

esperar_entrada:
    ACALL ler_teclado       ; Função que lê a tecla pressionada
    MOV A, R1              ; Carrega o LED pressionado
    MOV P1, A              ; Acende o LED correspondente
    ACALL delay_curto      ; Aguarda um pequeno intervalo
    MOV P1, #00H           ; Apaga o LED
    INC R1                 ; Avança para o próximo LED
    MOV A, R1
    MOV B, 34H             ; Número de LEDs a serem comparados
    CMP A, B               ; Verifica se o número de LEDs digitados é igual ao nível
    JNZ esperar_entrada    ; Se ainda não acertou todos os LEDs, repete

verificar_acertos:
    MOV A, 30H             ; Índice da sequência gerada
    MOV B, 31H             ; Índice da sequência digitada
    CMP A, B               ; Verifica se as sequências batem
    JZ acerto              ; Se as sequências são iguais, acerto
    MOV 33H, #01H          ; Caso contrário, houve erro
    ACALL exibir_erro      ; Função que exibe mensagem de erro
    SJMP fim_jogo

acerto:
    MOV 32H, #00H          ; Zera o contador de acertos
    MOV 33H, #00H          ; Zera o erro
    ACALL proximo_nivel    ; Função para ir para o próximo nível

fim_jogo:
    ; Exibe a mensagem de fim de jogo e retorna ao início

proximo_nivel:
    INC 34H                ; Aumenta o nível
    MOV A, 34H
    CMP A, #06H            ; Checa se o nível é maior que 5
    JZ jogo_completo       ; Se chegou ao nível 6, jogo completo
    SJMP gerar_sequencia   ; Volta para gerar sequência do próximo nível

jogo_completo:
    ; Exibe a mensagem de vitória e reinicia o jogo

ACALL delay_long
SJMP gerar_sequencia

