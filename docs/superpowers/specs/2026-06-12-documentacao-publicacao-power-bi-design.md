# Design: documentacao e preparacao publica do case Power BI

## Objetivo

Preparar o repositorio como um case publico de portfolio sobre Power BI, modelagem
dimensional e analise de vendas. A empresa usada no desafio deve aparecer apenas
como contexto ficticio, sem repeticao promocional ou aparencia de projeto oficial.

O repositorio permanecera privado nesta etapa, mas sera organizado para uma
publicacao futura. As tres planilhas podem ser versionadas e devem ser descritas
como dados sinteticos do desafio.

## Entregas

### README executivo

O `README.md` deve funcionar como pagina inicial do portfolio e conter:

- titulo generico do case;
- resumo do problema e da solucao;
- aviso de dados ficticios e projeto nao oficial;
- tecnologias e competencias demonstradas;
- imagem do dashboard;
- principais decisoes de tratamento e modelagem;
- diagrama do modelo estrela em Mermaid;
- lista resumida de indicadores e visuais;
- estrutura relevante do repositorio;
- instrucoes para abrir, configurar e atualizar o projeto;
- link para a documentacao tecnica detalhada.

O texto deve priorizar a solucao, as decisoes analiticas e a capacidade tecnica.
O nome da empresa ficticia deve ser usado somente quando necessario para
identificar os arquivos ou explicar a origem do desafio.

### Documentacao tecnica do Power BI

O arquivo `docs/modelo-power-bi.md` deve ser gerado a partir do modelo aberto no
Power BI Desktop e dos arquivos PBIP. Ele deve documentar:

- tabelas de negocio e tabela tecnica de medidas;
- colunas, tipos e finalidade;
- transformacoes principais em Power Query;
- relacionamentos, cardinalidade e direcao de filtro;
- medidas DAX, pasta de exibicao, formato e descricao;
- paginas e visuais, incluindo tipo, campos e objetivo analitico;
- limitacoes conhecidas da base de metas;
- instrucoes para manutencao do catalogo.

Tabelas automaticas internas de data nao devem ser apresentadas como parte do
modelo de negocio depois da correcao estrutural.

## Modelo dimensional

O modelo deve convergir para uma estrutura estrela com `fVendas` no centro:

- `dCalendario[Data]` 1:* `fVendas[DATA]`;
- `dClientes[ID_CLIENTE]` 1:* `fVendas[ID_CLIENTE]`;
- `dMetas[CHAVE_META]` 1:* `fVendas[CHAVE_META]`;
- `Medidas` como tabela desconectada e tecnica.

Os filtros devem ser unidirecionais, das dimensoes para a fato. A tabela
`dCalendario` deve ser a tabela de datas oficial, e o recurso automatico de
data/hora deve ser desativado para remover tabelas locais redundantes.

O relacionamento com `dMetas` representa apenas as combinacoes com meta
existente. A documentacao deve deixar claro que a origem possui cobertura
parcial e nao contem ano, portanto as metas sao interpretadas como recorrentes.

## Portabilidade das fontes

As consultas nao devem conter caminhos absolutos da maquina do autor. Sera criado
um parametro de texto para a pasta das fontes, usado pelas consultas das tres
planilhas.

O README deve explicar como alterar esse parametro para a pasta clonada antes da
primeira atualizacao. A solucao deve continuar funcionando localmente no Power BI
Desktop sem depender de o repositorio estar publico.

## Preparacao para publicacao

Antes do envio ao remoto:

- ampliar o `.gitignore` para caches, configuracoes pessoais e artefatos locais;
- remover do indice arquivos locais do Power BI que ja estejam rastreados;
- excluir configuracoes pessoais como `.claude/settings.local.json`;
- manter PBIX, PBIP, planilhas, tema, imagem e documentacao do case;
- verificar que nao existem credenciais, tokens ou caminhos pessoais expostos;
- adicionar uma licenca adequada para portfolio e dados sinteticos;
- definir descricao e topics do GitHub;
- manter a visibilidade privada.

Descricao proposta:

> Case de Power BI com ETL em Power Query, modelo estrela, medidas DAX e dashboard executivo para analise de vendas, metas e qualidade de dados.

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

- leitura do modelo ativo com o Power BI Modeling MCP;
- confirmacao das tabelas, medidas e relacionamentos apos as correcoes;
- comparacao entre a documentacao e os arquivos PBIP;
- verificacao estrutural dos JSON/TMDL alterados;
- busca por caminhos pessoais, segredos e configuracoes locais;
- revisao do Mermaid e dos links do README;
- `git status` e diff final para confirmar o escopo;
- envio dos commits ao remoto atual sem alterar a visibilidade.

## Fora de escopo

- publicar o repositorio;
- criar novas paginas ou novos indicadores no dashboard;
- substituir os dados sinteticos;
- completar a base de metas;
- reformular toda a identidade visual do relatorio.
