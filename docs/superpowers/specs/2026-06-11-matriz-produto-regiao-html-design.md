# Matriz HTML de Produto por Regiao

## Objetivo

Substituir a matriz nativa de produto por regiao por um visual HTML Content
dinamico, mantendo a mesma posicao e dimensoes e preservando o contexto de
filtros do relatorio.

Esta etapa tambem corrige propriedades de formatacao invalidas adicionadas aos
containers dos demais visuais.

## Correcao de schema

Os erros de abertura do PBIP foram causados por propriedades nao aceitas no
schema `visualContainer/2.10.0`:

- `visualContainerObjects.shadow`;
- `visualContainerObjects.title[].properties.color`;
- `visualContainerObjects.subTitle[].properties.color`.

Essas propriedades serao removidas de todos os `visual.json`. O script
`scripts/apply-neutral-dashboard-theme.js` tambem sera corrigido para nao
reintroduzi-las.

O tema global continuara responsavel pelas cores de titulo e subtitulo. Os
containers manterao somente propriedades aceitas, como exibicao, tipografia,
tamanho, peso e alinhamento.

## Visual substituido

O visual nativo atual:

- id: `a50db6ca0c6445255352`;
- tipo: `pivotTable`;
- posicao: `x = 1037.5`, `y = 1150`;
- dimensoes: `827.5 x 455`;
- linhas: `fVendas[ID_PRODUTO]`;
- colunas: `fVendas[REGIAO]`;
- valores: `[Total Vendas]`.

sera substituido no mesmo id e na mesma area por um visual
`htmlContent443BE3AD55E043BF878BED274D3A6855`.

## Estrutura visual

O bloco tera o titulo **Vendas por Produto e Regiao** e uma linha auxiliar
explicando que o percentual representa a participacao da regiao no total do
produto.

A tabela tera:

- primeira coluna **Produto**, alinhada a esquerda;
- uma coluna para cada regiao visivel no contexto de filtro, centralizada;
- coluna final **Total**, centralizada;
- produtos ordenados do maior para o menor total de vendas;
- regioes ordenadas alfabeticamente;
- linha final **Total geral**.

O identificador do produto sera exibido com o prefixo `P`, evitando o rotulo
tecnico `ID_PRODUTO`.

## Conteudo das celulas

Cada celula de produto por regiao exibira:

- valor absoluto no formato `R$ #,##0`;
- abaixo ou ao lado, em fonte menor, o percentual no formato `0.0%`;
- texto auxiliar **do produto**.

O percentual sera calculado como:

```dax
DIVIDE(
    vendas do produto na regiao,
    vendas totais do produto em todas as regioes visiveis
)
```

Filtros externos de ano, canal e demais dimensoes permanecerao ativos. Apenas o
filtro da regiao da celula sera removido para calcular o denominador da linha.

Celulas sem venda exibirao travessao e `0,0%`. O total do produto exibira
`100,0%`. A linha **Total geral** mostrara, em cada regiao, o valor regional e a
participacao daquela regiao nas vendas gerais do contexto.

## Estilo

O visual seguira o tema neutro aprovado:

- fundo branco;
- borda `#EDE8E1`;
- texto principal `#24212E`;
- texto secundario `#6E5746`;
- cabecalho `#566164` com texto branco;
- destaque `#B08D72`;
- linhas alternadas em `#FCF7F0`;
- cantos arredondados;
- tipografia Segoe UI;
- valores e percentuais centralizados;
- coluna Produto alinhada a esquerda;
- intensidade sutil de fundo baseada na participacao da celula no produto.

O conteudo devera caber na area atual. Se a quantidade de produtos exceder a
altura disponivel, o corpo da tabela podera usar rolagem vertical interna,
mantendo o cabecalho fixo.

## Implementacao

Uma nova medida DAX `HTML Vendas Produto Regiao` sera adicionada a
`Medidas.tmdl`. Ela construira:

1. a lista de regioes visiveis;
2. a lista de produtos visiveis;
3. o cabecalho dinamico;
4. as celulas com valor e percentual;
5. os totais por produto;
6. a linha de total geral;
7. o HTML e CSS completos.

O `visual.json` existente sera convertido para HTML Content e vinculado apenas
a essa medida. Cross-filter, hyperlinks e selecao de texto ficarao desativados.
O visual continuara respondendo aos filtros do relatorio, mas nao filtrara
outros visuais por clique.

## Validacao

A entrega sera considerada pronta quando:

- nenhum `visual.json` contiver o grupo `shadow`;
- titulo e subtitulo nao contiverem a propriedade invalida `color`;
- o script de tema nao gerar essas propriedades;
- o visual `a50db6ca0c6445255352` for HTML Content;
- posicao e dimensoes do visual permanecerem inalteradas;
- o visual estiver vinculado a `Medidas.HTML Vendas Produto Regiao`;
- o HTML contiver Produto, regioes dinamicas e Total;
- a coluna Produto estiver alinhada a esquerda;
- valores numericos estiverem centralizados;
- cada celula tiver valor em R$ e percentual do produto;
- o TMDL puder ser importado pelo modelador;
- todos os JSON do relatorio forem validos;
- os testes existentes de tema e cards continuarem passando.

A validacao visual final sera feita abrindo
`case-bi-construtora-pride.pbip` com o Power BI Desktop depois das verificacoes
estruturais.
