# Tema Neutro para os Visuais

## Objetivo

Aplicar uma identidade visual neutra e organizacional a todos os componentes da
pagina, preservando tipos de visual, posicoes, dimensoes, campos, medidas,
filtros e interacoes atuais.

O arquivo `bi-construtura-pride-tema.json` sera a fonte da paleta. Ajustes
especificos nos `visual.json` complementarao o que o tema global nao controla
com precisao.

## Escopo

Serao customizados:

- dois filtros Smart Filter: ano e regiao;
- grafico de colunas por regiao;
- grafico donut por canal;
- grafico combinado por trimestre;
- grafico de barras por produto;
- matriz de produto por regiao;
- tabela de desempenho temporal;
- bloco HTML dos seis cards;
- fundo e propriedades globais da pagina e do relatorio.

Nao serao alterados:

- medidas e regras analiticas;
- campos vinculados aos visuais;
- filtros ou comportamento de interacao;
- posicoes, larguras e alturas atuais;
- altura atual da pagina, definida em 2300;
- ordenacao e semantica dos dados.

As alteracoes nao commitadas presentes no projeto no inicio desta etapa serao
tratadas como a base atual e nao serao revertidas.

## Paleta

A identidade principal usa os valores do tema neutro:

- texto principal: `#24212E`;
- texto secundario: `#6E5746`;
- texto terciario: `#928F8B`;
- fundo da pagina: `#FCF7F0`;
- fundo de visual: `#FFFFFF`;
- fundo neutro: `#EDE8E1`;
- destaque de tabela: `#566164`;
- destaque central: `#B08D72`;
- positivo: `#6B797D`;
- neutro: `#8C705B`;
- negativo: `#4D332C`.

As series de dados priorizarao, nesta ordem:

1. `#6B797C`;
2. `#362B2B`;
3. `#B08D72`;
4. `#40484A`;
5. `#86989C`;
6. `#5B3D35`;
7. `#928F8B`.

## Sistema de containers

Todos os visuais analiticos usarao fundo branco, borda clara derivada de
`#EDE8E1`, raio entre 10 e 14 px e sombra discreta quando a propriedade for
suportada pelo Power BI.

Titulos usarao Segoe UI, cor `#24212E`, peso semibold e alinhamento a esquerda.
Subtitulos e textos auxiliares usarao `#6E5746`.

O fundo da pagina sera `#FCF7F0`, sem textura ou gradiente. O espacamento atual
sera preservado.

## Filtros

Os filtros de ano e regiao manterao o Smart Filter atual. Eles receberao:

- fundo branco;
- borda `#EDE8E1`;
- cantos arredondados;
- titulo em `#24212E`;
- texto de entrada em `#6E5746`;
- selecao e realce em `#B08D72`;
- icones e busca em tons neutros;
- cabecalho visual oculto quando nao for necessario para uso.

## Graficos

### Colunas por regiao

As colunas usarao a primeira cor da paleta. Rotulos de dados ficarao visiveis em
`#24212E`. Eixo de categoria e eixo de valores usarao texto secundario, linhas
de grade discretas e sem contorno pesado.

### Donut por canal

As fatias seguirao a ordem da paleta. A legenda sera limpa, com texto secundario
e marcadores consistentes. Rotulos devem priorizar categoria e percentual sem
poluir o centro. O container seguira o mesmo acabamento dos demais graficos.

### Combinado por trimestre

As colunas usarao `#6B797C`; a linha de media usara `#B08D72`, com espessura
suficiente para diferenciacao. A legenda identificara claramente as duas
series. Eixos, rotulos e grades seguirao o sistema neutro.

### Barras por produto

As barras usarao `#6B797C`, com rotulos em `#24212E`. O eixo de produtos
permanecera legivel e as linhas de grade terao baixo contraste.

## Matriz e tabela

A matriz e a tabela receberao:

- cabecalho `#566164` com texto branco;
- corpo branco;
- linhas alternadas em `#FCF7F0`;
- divisores `#EDE8E1`;
- texto principal `#24212E`;
- totais em fundo `#EDE8E1`, com peso semibold;
- padding vertical consistente;
- alinhamento numerico preservado;
- borda externa e cantos arredondados no container.

Regras de formatacao condicional ja existentes serao recoloridas com a escala
negativo `#4D332C`, neutro `#8C705B` e positivo `#6B797D`. Nenhum novo limite
ou criterio analitico sera criado. Campos sem regra permanecerao neutros.

## Cards HTML

O bloco HTML existente sera recolorido sem mudar conteudo, ordem ou dimensoes:

- remover azul-marinho e dourado;
- valores em `#24212E`;
- rotulos em `#6E5746`;
- acento superior em `#B08D72`;
- bordas em `#EDE8E1`;
- estados positivos em `#6B797D`;
- estados de atencao em `#4D332C`;
- sombra mais suave e coerente com os demais containers.

## Tema global

O arquivo `bi-construtura-pride-tema.json` sera expandido com configuracoes de
`visualStyles` para definir defaults de container, titulo, legenda, eixos,
rotulos, tabela e matriz. O tema sera incorporado ao pacote de recursos do
relatorio e referenciado como tema customizado.

As configuracoes especificas existentes em cada visual serao revisadas para nao
sobrescrever o tema com cores antigas ou propriedades conflitantes.

## Validacao

A implementacao sera considerada pronta quando:

- o JSON do tema e todos os JSON do relatorio forem validos;
- o TMDL puder ser importado pelo modelador Power BI;
- nenhum visual mudar de posicao, dimensao, tipo ou binding;
- os nove componentes listados no escopo usarem a paleta neutra;
- o bloco HTML nao contiver as cores azul-marinho e dourado anteriores;
- o relatorio referenciar o tema neutro customizado;
- tabela e matriz tiverem cabecalho, linhas alternadas e totais coerentes;
- filtros e graficos tiverem containers, titulos e textos consistentes;
- as alteracoes preexistentes no worktree forem preservadas.

A validacao visual final sera feita abrindo
`case-bi-construtora-pride.pbip` no Power BI Desktop depois das verificacoes
estruturais.
