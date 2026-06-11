# Matriz Farol com Deneb

## Objetivo

Substituir a matriz nativa existente pelo visual customizado Deneb, mantendo a
posição e as dimensões atuais no relatório PBIP. O resultado deve se aproximar
da referência fornecida, sem alterar a lógica das medidas existentes.

## Escopo

- Alterar o visual `29606862c6d4d2ebb607` na página
  `516f47fa1bac5767e01c`.
- Preservar a posição, o tamanho, a ordem de tabulação e as interações
  aplicáveis do visual atual.
- Usar os campos já vinculados:
  - `dMetas[PRODUTO_ID]`
  - `dMetas[REGIÃO]`
  - `dMetas[TRIMESTRE]`
  - `dCalendario[Ano]`
  - `Medidas[% Atingimento]`
- Não modificar a definição DAX de `% Atingimento`.

## Estrutura Visual

Cada combinação de produto, região e trimestre será exibida em uma única linha,
com rótulo no formato:

`Produto · Região · Trimestre`

Os anos serão apresentados como colunas. As células mostrarão o percentual de
atingimento centralizado. O visual ocupará o mesmo retângulo usado atualmente
pela matriz.

## Estilo

- Fundo branco.
- Cabeçalhos em azul-escuro, caixa alta e peso seminegrito.
- Rótulos das combinações em azul-escuro e negrito.
- Divisórias horizontais finas em cinza-azulado claro.
- Sem grade vertical aparente.
- Espaçamento interno compacto e consistente.
- Percentuais apresentados em indicadores arredondados, semelhantes a
  pílulas.

## Formatação Condicional

Aplicar as seguintes faixas somente quando `% Atingimento` não for vazio:

| Faixa | Aparência |
| --- | --- |
| Maior ou igual a 100% | Fundo verde-claro e texto verde |
| De 70% até abaixo de 100% | Fundo amarelo-claro e texto âmbar |
| Abaixo de 70% | Fundo vermelho-claro e texto vermelho |

Quando a medida retornar `BLANK()`, a célula permanecerá vazia, sem texto,
indicador ou cor de fundo.

## Implementação

O visual será convertido para Deneb e receberá uma especificação Vega ou
Vega-Lite embutida na definição PBIP. A transformação dos dados deve:

1. formar o rótulo da combinação;
2. organizar os anos como colunas;
3. manter uma linha por combinação;
4. desenhar os indicadores somente para valores não vazios;
5. formatar os valores existentes como percentuais inteiros.

A implementação não adicionará tabelas auxiliares nem modificará as fontes de
dados.

## Compatibilidade

O arquivo PBIP deverá abrir no Power BI Desktop com o visual no mesmo local. O
Deneb precisa estar disponível no relatório como visual organizacional ou
visual do AppSource. Caso o Power BI solicite autorização para o visual
customizado, essa autorização será uma etapa manual do ambiente do usuário.

## Validação

- Validar os arquivos JSON alterados sintaticamente.
- Confirmar que os campos referenciados existem no modelo semântico.
- Confirmar que posição e dimensões são idênticas às do visual original.
- Confirmar as três faixas de cor.
- Confirmar que valores vazios não geram `0%`.
- Abrir o PBIP no Power BI Desktop para a validação visual final.

## Fora de Escopo

- Alterar medidas DAX ou regras de negócio.
- Preencher valores ausentes com zero.
- Redesenhar outros visuais da página.
- Alterar o tamanho ou a posição reservada para a matriz.
