# Seção de Metas com HTML Content

## Objetivo

Substituir somente a seção atual de metas pelo visual customizado HTML Content,
mantendo todos os demais visuais e suas posições inalterados. A nova seção deve
explicar cobertura, execução e qualidade da base de metas com leitura mais
direta que a matriz anual.

## Visual

Usar o visual:

- Nome: HTML Content
- Publicador: Daniel Marsh-Patrick
- ID: `htmlContent443BE3AD55E043BF878BED274D3A6855`
- Versão instalada: `1.6.0.0`

O visual ocupará o mesmo retângulo atualmente usado pelo Deneb
`29606862c6d4d2ebb607`.

## Composição

### Cabeçalho

Título: `Controle das metas oficiais`

Subtítulo curto explicando que as metas são definidas por produto, região e
trimestre e tratadas como recorrentes por ano porque a base não possui uma
coluna de ano.

### Indicadores

Exibir três cartões compactos:

1. **Cobertura de metas**
   - Usa `[Cobertura de Metas]`.
   - Mostra percentual e quantidade de combinações definidas.

2. **Execução das metas**
   - Mostra vendas vinculadas às combinações oficiais sobre o valor total das
     metas nos ciclos analisados.
   - Requer medida específica para não misturar vendas sem meta.

3. **Combinações com venda**
   - Mostra quantas combinações oficiais tiveram ao menos uma venda compatível.
   - Exibe o total sobre as cinco combinações cadastradas.

### Comparação por Meta

Exibir uma linha para cada combinação cadastrada em `dMetas`:

- produto;
- região;
- trimestre;
- valor da meta;
- total vendido correspondente;
- percentual de atingimento;
- barra horizontal de progresso;
- estado textual: `Atingida`, `Em andamento` ou `Sem venda compatível`.

As linhas devem partir de `dMetas`, não da tabela de vendas. Assim, combinações
sem vendas continuam visíveis.

## Regras Visuais

- Fundo branco e bordas arredondadas.
- Tipografia Segoe UI.
- Azul-escuro para títulos e rótulos.
- Verde para atingimento maior ou igual a 100%.
- Âmbar para atingimento entre 70% e 99,99%.
- Vermelho para atingimento abaixo de 70% quando há venda.
- Cinza para combinações sem venda compatível.
- Barras limitadas visualmente a 100%, mantendo o percentual real no texto.

## Medidas Existentes

Reutilizar:

- `[Total Vendas]`
- `[Total Meta]`
- `[% Atingimento]`
- `[Gap Meta R$]`
- `[Cobertura de Metas]`

## Medidas Auxiliares

Criar medidas apenas quando necessárias para manter a semântica correta:

- `Vendas Metas Oficiais`: vendas vinculadas às chaves existentes em `dMetas`.
- `Valor Metas Ciclos`: valor das metas oficiais multiplicado pela quantidade
  de anos do período selecionado.
- `% Execução Metas Oficiais`: divisão entre vendas das metas oficiais e valor
  das metas nos ciclos.
- `Combinações Meta com Venda`: quantidade de chaves oficiais com vendas.
- `HTML Controle Metas`: medida que monta todo o HTML e CSS da seção.

As medidas auxiliares ficarão na tabela `Medidas`, dentro da pasta de exibição
`Metas`.

## Interação

O HTML será produzido por uma única medida. Portanto:

- filtros da página continuarão recalculando os indicadores;
- o visual será principalmente informativo;
- cliques em linhas individuais não farão cross-filter dos demais visuais;
- tooltips independentes poderão ser incorporados por atributos HTML quando
  agregarem informação útil.

## Tratamento de Dados

- A região deve vir de `dMetas[REGIÃO]`.
- O produto deve vir de `dMetas[PRODUTO_ID]`.
- O trimestre deve vir de `dMetas[TRIMESTRE]`.
- As combinações sem venda não serão convertidas para `0%`; serão exibidas como
  `Sem venda compatível`.
- O cálculo não deve considerar vendas de combinações que não existem em
  `dMetas`.

## Validação

- Confirmar as cinco combinações de `dMetas` no HTML.
- Confirmar que somente P102/Sul/Q2 e P103/Leste/Q3 possuem vendas compatíveis
  nas fontes atuais.
- Confirmar que P101, P104 e P105 aparecem como sem venda.
- Validar as novas medidas no modelo.
- Validar o HTML gerado e a definição PBIR do visual.
- Confirmar que nenhum outro visual da página foi modificado.

## Fora de Escopo

- Alterar as bases Excel.
- Redesenhar outros visuais.
- Criar interação por linha com cross-filter.
- Alterar regras de metas ou preencher vendas ausentes.
