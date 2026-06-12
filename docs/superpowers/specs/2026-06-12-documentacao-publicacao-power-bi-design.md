# Design: case analitico em Power BI orientado a decisoes

> **Atualização de escopo em 12/06/2026:** o modelo semântico não será
> modificado. A documentação deve refletir a implementação atual e registrar
> os pontos de portabilidade e modelagem como limitações conhecidas.

## Finalidade

Apresentar uma solucao analitica desenvolvida para integrar bases separadas de
vendas, clientes e metas, estruturar comparacoes confiaveis e identificar quais
informacoes precisam ser validadas antes de uma decisao.

O case deve demonstrar conhecimento em Power BI, Power Query, modelagem de dados,
DAX e apresentacao analitica por meio das decisoes realizadas no projeto. O texto
nao deve mencionar processo seletivo, entrevista ou avaliacao profissional.

A empresa presente nos arquivos deve aparecer somente como contexto ficticio.
Nomes, valores e bases serao declarados como dados sinteticos do desafio.

## Principio editorial

O README nao deve elogiar ou classificar numeros sem um criterio definido.
Expressoes subjetivas como "resultado bom", "numero interessante" ou
"desempenho ruim" devem ser evitadas.

Cada achado analitico deve seguir esta estrutura:

1. **Evidencia:** o que os dados mostram, com numero e periodo.
2. **Hipotese:** quais explicacoes podem ser consideradas, sem trata-las como
   conclusoes.
3. **Validacao necessaria:** quais dados, regras ou contextos precisam ser
   confirmados.
4. **Acao possivel:** o que pode ser feito depois da validacao.
5. **Resultado esperado:** qual resposta ou melhoria a acao deve produzir.

Os numeros devem ser exatos e acompanhados das limitacoes da base sintetica.

## Estrutura do README

### 1. Visao geral

Explicar de forma direta que o projeto:

- integrou bases de vendas, clientes e metas;
- tratou problemas de integridade e granularidade;
- estruturou um modelo dimensional;
- criou indicadores e visuais para investigar desempenho, metas e qualidade;
- converteu os resultados em hipoteses e proximas validacoes.

### 2. Problemas encontrados e decisoes tecnicas

Cada decisao deve ser apresentada no formato
**problema -> implementacao -> ganho**:

- **Modelo estrela**
  - Problema: informacoes comerciais distribuidas em bases com granularidades
    diferentes.
  - Implementacao: `fVendas` no centro, relacionada a `dCalendario`,
    `dClientes` e `dMetas`.
  - Ganho: filtros previsiveis e separacao entre eventos, atributos e metas.

- **Calendario unico**
  - Problema: tabelas automaticas de data criam caminhos temporais redundantes.
  - Implementacao: usar apenas `dCalendario` como tabela de datas oficial.
  - Ganho: comparacoes temporais consistentes e identificacao de periodos
    incompletos.

- **Relacionamentos unidirecionais**
  - Problema: filtros bidirecionais e uma relacao `1:1` podem produzir
    propagacao ambigua.
  - Implementacao: dimensoes filtrando a fato em relacoes `1:*`.
  - Ganho: comportamento do modelo mais previsivel e auditavel.

- **Tratamento de clientes**
  - Problema: IDs duplicados na base cadastral e IDs de vendas sem cadastro.
  - Implementacao: consolidar duplicidades e criar registros explicitos para
    clientes nao identificados.
  - Ganho: preservar toda a receita sem esconder falhas de cadastro.

- **Tabela de medidas**
  - Problema: regras de negocio dispersas dificultam auditoria.
  - Implementacao: concentrar as medidas DAX na tabela tecnica `Medidas`.
  - Ganho: manutencao, organizacao e rastreabilidade dos indicadores.

- **Parametro para as fontes**
  - Problema: consultas M usam caminhos absolutos da maquina do autor.
  - Implementacao: parametro de pasta compartilhado pelas tres consultas.
  - Ganho: atualizacao do projeto depois de clonar o repositorio.

- **Visuais orientados a investigacao**
  - Problema: KPIs isolados nao explicam causas nem qualidade da informacao.
  - Implementacao: combinar tendencia, composicao, cobertura e recortes.
  - Ganho: transformar variacoes em perguntas verificaveis.

### 3. Modelo de dados

Incluir um diagrama Mermaid com:

- `dCalendario[Data]` 1:* `fVendas[DATA]`;
- `dClientes[ID_CLIENTE]` 1:* `fVendas[ID_CLIENTE]`;
- `dMetas[CHAVE_META]` 1:* `fVendas[CHAVE_META]`;
- `Medidas` como tabela tecnica desconectada.

O diagrama deve mostrar apenas o modelo de negocio, sem tabelas automaticas
internas do Power BI.

### 4. Hipoteses prioritarias

#### Metas incompletas

- Evidencia: existem metas para 5 das 50 combinacoes possiveis de produto e
  regiao, uma cobertura de 10%. Somente R$ 8.893, ou 3,2% da receita total,
  coincide com uma chave produto-regiao-trimestre presente na base de metas.
- Hipotese: a base pode representar uma amostra, um planejamento parcial ou um
  cadastro incompleto.
- Validacao necessaria: confirmar a granularidade esperada, a ausencia da
  dimensao de ano, a recorrencia das metas e se combinacoes ausentes significam
  meta zero ou dado nao informado.
- Acao possivel: revisar a estrutura e completar as metas somente depois de
  confirmar as regras.
- Resultado esperado: cobertura, atingimento e gap de meta calculados sobre uma
  referencia valida.

#### Queda de receita em 2026

- Evidencia: a receita passou de R$ 77.037 em 2025 para R$ 56.651 em 2026,
  queda de 26,5%. As transacoes passaram de 25 para 24, queda de 4%, enquanto o
  ticket medio caiu de R$ 3.081,48 para R$ 2.360,46, reducao de 23,4%.
- Recortes: Oeste caiu 78,1%; Loja caiu 67,7%; P101, P103 e P105 nao registraram
  vendas em 2026.
- Hipotese: a queda pode estar associada a mudanca de mix, indisponibilidade de
  produtos, alteracao de canal/regiao ou incompletude da carga.
- Validacao necessaria: confirmar completude do periodo, disponibilidade do
  portfolio, mudancas comerciais e consistencia das fontes.
- Acao possivel: decompor a variacao por produto, regiao, canal, cliente e
  ticket depois da validacao.
- Resultado esperado: distinguir uma mudanca comercial real de um problema de
  cobertura ou qualidade dos dados.

#### Cadastro de clientes

- Evidencia: os IDs 200, 201, 205 e 207 nao existem na base cadastral e
  representam 40 transacoes, R$ 109.370 e 39,4% da receita. Os IDs 202, 204 e
  208 possuem mais de um registro na origem.
- Hipotese: existem falhas de integracao, historico sem cadastro correspondente
  ou ausencia de uma regra para o registro mestre.
- Validacao necessaria: reconciliar os IDs com a fonte responsavel e definir
  como atributos conflitantes devem ser resolvidos.
- Acao possivel: corrigir o cadastro mestre e monitorar novas vendas sem
  correspondencia.
- Resultado esperado: segmentacoes e atribuicoes por cliente mais confiaveis,
  sem perda da receita durante o tratamento.

#### Periodos incompletos

- Evidencia: 2027 possui apenas duas transacoes, realizadas em 10 e 25 de
  janeiro, com receita total de R$ 3.490.
- Hipotese: o periodo pode representar uma carga parcial, e nao um ano fechado.
- Validacao necessaria: confirmar a data de corte e o calendario de atualizacao.
- Acao possivel: marcar periodos abertos ou limitar comparacoes a intervalos
  equivalentes.
- Resultado esperado: evitar comparacoes anuais ou variacoes percentuais
  enganosas.

Outros achados so devem entrar no README quando tiverem evidencia e impacto
comparaveis. Canal, produto ou regiao nao devem ser destacados apenas por ocupar
a primeira ou a ultima posicao.

### 5. Dashboard e indicadores

Apresentar a imagem do dashboard e explicar o papel de cada grupo de visual:

- resumo de receita, volume, ticket e variacao;
- distribuicao por regiao e canal;
- tendencia trimestral e comparacao temporal;
- matriz de produto por regiao;
- controle da cobertura e execucao de metas;
- filtros de ano e regiao.

O README deve resumir os indicadores. A definicao completa deve ficar na
documentacao tecnica.

### 6. Como executar

Explicar:

- como abrir o arquivo `.pbip`;
- como configurar o parametro da pasta das fontes;
- como atualizar o modelo;
- quais visuais personalizados sao utilizados;
- onde consultar o catalogo tecnico.

## Documentacao tecnica

O arquivo `docs/modelo-power-bi.md` deve ser produzido a partir do modelo aberto
no Power BI Desktop, consultado pelo Power BI Modeling MCP, e conferido contra
os arquivos PBIP.

Ele deve conter:

- finalidade, granularidade e transformacoes das tabelas;
- colunas, tipos e uso analitico;
- relacionamentos, cardinalidade e direcao de filtro;
- catalogo das medidas DAX, incluindo formula, formato, pasta e descricao;
- catalogo dos visuais, campos usados e objetivo;
- parametros e fontes;
- limitacoes conhecidas;
- orientacao para manter o catalogo atualizado.

## Preparacao do repositorio

Antes do envio ao remoto:

- ampliar o `.gitignore`;
- remover do indice caches e configuracoes locais ja rastreados;
- excluir configuracoes pessoais;
- manter PBIX, PBIP, planilhas sinteticas, tema, imagens e documentacao;
- verificar caminhos pessoais, segredos e tokens;
- incluir uma licenca compativel com um portfolio de codigo e dados sinteticos;
- configurar descricao e topics;
- manter o repositorio privado.

Descricao proposta:

> Case analitico em Power BI com Power Query, modelo estrela e medidas DAX para investigar vendas, metas e qualidade dos dados.

Topics propostos:

- `power-bi`
- `power-query`
- `dax`
- `data-analytics`
- `business-intelligence`
- `star-schema`
- `data-modeling`
- `dashboard`
- `portfolio-project`
- `pbip`

## Validacao

A entrega deve ser validada por:

- consultas ao modelo ativo pelo Power BI Modeling MCP;
- reconciliacao dos numeros do README com as bases sinteticas;
- confirmacao das tabelas, medidas e relacionamentos depois das correcoes;
- comparacao da documentacao tecnica com os arquivos PBIP;
- validacao estrutural de JSON, TMDL e Mermaid;
- busca por caminhos pessoais, credenciais e configuracoes locais;
- revisao do diff para preservar alteracoes preexistentes;
- envio dos commits ao remoto atual sem alterar a visibilidade.

## Fora de escopo

- tornar o repositorio publico;
- inventar explicacoes para as variacoes;
- completar ou alterar os dados sinteticos;
- prescrever acoes comerciais antes das validacoes;
- criar novos indicadores ou reformular o dashboard sem necessidade documental.
