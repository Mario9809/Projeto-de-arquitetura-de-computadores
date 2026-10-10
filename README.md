# Jogo de Memória Visual em Assembly (8051)

Projeto acadêmico de **Arquitetura de Computadores**, desenvolvido em 2025 no **Centro Universitário FEI**, utilizando a linguagem **Assembly para o microcontrolador 8051** e o simulador **EdSim51**.

A proposta é reproduzir a dinâmica de um jogo de memória visual: o programa apresenta uma sequência de LEDs, e o jogador tenta repeti-la por meio de um teclado matricial.

> **Estado do projeto:** protótipo acadêmico. O repositório documenta a lógica implementada; alguns detalhes de entrada/saída e temporização ainda precisam ser revisados e validados no simulador, conforme a seção [Limitações conhecidas](#limitações-conhecidas).

## Objetivo

Explorar, na prática, conceitos de programação de baixo nível e arquitetura de computadores, incluindo:

- Uso de registradores e do acumulador do 8051;
- Acesso e organização de dados na RAM interna;
- Instruções de comparação, desvio e repetição;
- Criação e chamada de sub-rotinas;
- Manipulação de portas de entrada e saída;
- Interação com LEDs e teclado matricial em ambiente simulado.

## Tecnologias utilizadas

| Tecnologia | Aplicação |
| --- | --- |
| Assembly 8051 | Implementação da lógica do jogo |
| Microcontrolador 8051 | Arquitetura-alvo do programa |
| EdSim51 | Simulação e inspeção do comportamento do programa |
| LEDs e teclado matricial | Interface visual e entrada do jogador |

## Como o jogo foi planejado

1. O programa inicia no **nível 1**.
2. O nível é sinalizado pelos LEDs.
3. Uma sequência é construída e armazenada na memória interna.
4. Os LEDs apresentam os elementos da sequência, um de cada vez.
5. O jogador tenta reproduzir a sequência no teclado matricial.
6. O programa compara cada entrada com o valor armazenado.
7. Se houver erro, executa o efeito visual de derrota e reinicia; se a sequência for completada, avança de nível.
8. Após completar o **nível 5**, executa o efeito visual de vitória e reinicia.

### Progressão de dificuldade

O tamanho da sequência é calculado pela expressão `NIVEL + 2`:

| Nível | Quantidade de elementos |
| :---: | :---: |
| 1 | 3 |
| 2 | 4 |
| 3 | 5 |
| 4 | 6 |
| 5 | 7 |

**Importante:** na versão atual, a rotina `GERAR_SEQUENCIA` armazena valores em ordem crescente (`0, 1, 2, ...`). Portanto, as sequências **não são aleatórias**. O aumento da dificuldade ocorre pelo comprimento da sequência.

## Estrutura do código

O arquivo principal é [`jogo.asm`](jogo.asm). Suas principais rotinas são:

| Rotina | Responsabilidade |
| --- | --- |
| `INICIO` / `NOVO_NIVEL` | Inicialização e preparação de cada rodada |
| `GERAR_SEQUENCIA` | Preenchimento da RAM com os elementos da sequência |
| `MOSTRAR_SEQUENCIA` | Percorrer a sequência e solicitar a exibição dos LEDs |
| `ACENDER_LED` | Construir uma máscara de bits para a saída de LEDs |
| `REPRODUZIR_SEQUENCIA` | Ler as respostas e compará-las com a sequência armazenada |
| `LER_TECLA` | Varredura do teclado matricial |
| `LER_LINHA_COLUNA` | Identificação da linha detectada |
| `PERDEU` | Sinalização de erro e reinício |
| `PISCAR_LEDS` | Efeito visual previsto para a conclusão do jogo |
| `DELAY_*` | Laços usados como rotinas de espera |

### Organização da memória

O código reserva endereços da RAM interna por meio da diretiva `EQU`:

```asm
NIVEL     EQU 30H  ; Nível atual
SEQUENCIA EQU 40H  ; Início da sequência na RAM
TECLA     EQU 50H  ; Tecla identificada
CONTADOR  EQU 51H  ; Tamanho da sequência
ACERTOS   EQU 52H  ; Acertos da rodada
```

O programa percorre os elementos da sequência usando **endereçamento indireto** (`@R0`), e utiliza registradores como contadores em seus laços.

## Como abrir no EdSim51

1. Acesse o [site do EdSim51](https://www.edsim51.com/) e obtenha o simulador de acordo com as instruções oficiais.
2. Faça o download deste repositório ou clone-o:

   ```bash
   git clone https://github.com/Mario9809/Projeto-de-arquitetura-de-computadores.git
   ```

3. Abra o EdSim51 e carregue o conteúdo de `jogo.asm` no editor de Assembly (ou abra o arquivo, conforme a versão do simulador).
4. Monte/execute o código utilizando os controles do simulador e acompanhe os registradores, a RAM e as portas de entrada e saída.
5. Utilize os controles do teclado e observe o painel de LEDs para investigar a lógica implementada.

**Nota:** esses passos permitem examinar e executar a implementação no ambiente de simulação, mas não garantem o funcionamento integral do jogo na revisão atual. Consulte as limitações abaixo.

## Aprendizados

O projeto serviu para exercitar a construção de uma aplicação sem bibliotecas de alto nível, exigindo atenção à organização de memória, às instruções do processador e à comunicação entre software e periféricos simulados.

## Contexto acadêmico

Desenvolvido como projeto da disciplina de **Arquitetura de Computadores** do curso de **Ciência da Computação — Centro Universitário FEI**, em **2025**.

## Repositório

[Projeto de Arquitetura de Computadores — GitHub](https://github.com/Mario9809/Projeto-de-arquitetura-de-computadores)
