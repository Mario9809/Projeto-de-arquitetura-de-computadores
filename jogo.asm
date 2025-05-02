

ORG 00H             




MOV 30H, #00H        ; indice_seq = 0
MOV 31H, #00H        ; indice_jogador = 0
MOV 32H, #00H        ; contador_acertos = 0
MOV 33H, #00H        ; erro_detectado = 0 (0 = false, 1 = erro ocorreu)



; Porta P1: LEDs
MOV P1, #00H         ; Inicializa LEDs apagados

; Porta P2: Display
MOV P2, #00H         ; Inicializa display desligado

; Porta P3: Keypad 4x3
MOV P3, #0FH

