# Roteiro de apresentação do dashboard

## 1. Contexto

O dashboard consolida 100 transações sintéticas entre janeiro de 2023 e
janeiro de 2027, com R$ 277.697 em receita. A apresentação deve separar:

- o que os dados comprovam;
- o que ainda é hipótese;
- qual validação é necessária;
- qual ação pode ser tomada após a validação.

## 2. Estrutura técnica

O modelo lógico usa `fVendas` como fato e `dCalendario`, `dClientes` e `dMetas`
como dimensões. As medidas estão centralizadas em `Medidas`.

Decisões que devem ser explicadas:

- a chave de meta combina produto, região e trimestre porque a origem não
  possui um identificador comum;
- clientes duplicados são consolidados e IDs órfãos são preservados para que a
  receita não desapareça nos relacionamentos;
- `AnoTri` padroniza o eixo trimestral;
- cards e tabelas densas usam HTML Content para controlar a leitura;
- algumas interações são bloqueadas para manter benchmarks globais.

O modelo físico atual também possui duas tabelas automáticas de data, quatro
relacionamentos ativos e três filtros bidirecionais. Esses itens são estado
atual, não uma recomendação de arquitetura.

## 3. Leitura dos KPIs

No contexto completo:

| Indicador | Valor |
|---|---:|
| Receita | R$ 277.697 |
| Transações | 100 |
| Ticket médio | R$ 2.777 |
| Canal com maior receita | Online, R$ 118.301 |
| Região com maior receita | Sul, R$ 75.298 |
| Região com menor receita | Leste, R$ 39.890 |

O card de variação anual deve ser apresentado somente após definir o período.
No contexto com múltiplos anos ele mostra 25,3%, enquanto 2025 contra 2026
resulta em -26,5%. A diferença demonstra a importância do contexto de filtro.

## 4. Queda de 2026

### Evidência

- 2025: R$ 77.037, 25 transações, ticket de R$ 3.081;
- 2026: R$ 56.651, 24 transações, ticket de R$ 2.360;
- receita: -26,5%;
- transações: -4,0%;
- ticket: -23,4%.

Principais movimentos:

| Segmento | Variação 2025 para 2026 |
|---|---:|
| Oeste | -R$ 22.433 |
| Sul | -R$ 9.388 |
| Norte | +R$ 11.450 |
| Loja | -R$ 18.142 |
| Online | -R$ 6.983 |
| Parceiro | +R$ 4.739 |

### Hipótese

A redução parece mais ligada a ticket e mix regional/de canal do que a uma
queda equivalente no volume.

### Validação

Abrir o resultado por mês, produto e cliente e conferir se 2026 está completo.
Depois, investigar preço, desconto, disponibilidade e cobertura comercial.

### Ação possível

Priorizar Oeste e Loja e comparar suas práticas com Norte e Parceiro.

### Resultado esperado

Identificar ações específicas para recuperar ticket e receita, sem aplicar a
mesma intervenção a todos os segmentos.

## 5. Metas

### Evidência

- 5 linhas de meta para 50 combinações produto-região;
- cobertura de 10%;
- R$ 8.893 de receita vinculada a chaves com meta;
- apenas 3,2% da receita possui uma chave de meta correspondente;
- a origem não possui ano.

### Hipótese

O arquivo de metas é parcial ou ilustrativo.

### Validação

Confirmar vigência, responsável, periodicidade e se a meta deve variar por ano.

### Ação possível

Reestruturar a origem no grão ano-produto-região-trimestre e criar um teste de
completude antes da carga.

### Resultado esperado

Indicadores de atingimento representativos e comparáveis.

## 6. Clientes

### Evidência

- IDs 200, 201, 205 e 207 não existem na origem de clientes;
- representam 40 transações, R$ 109.370 e 39,4% da receita;
- IDs 202, 204 e 208 aparecem duplicados;
- as vendas desses IDs representam R$ 77.104 e 27,8% da receita.

### Hipótese

As bases de vendas e cadastro não compartilham o mesmo controle de identidade.

### Validação

Reconciliar os sete IDs com a fonte cadastral e definir o registro oficial.

### Ação possível

Adicionar chave única, controle de órfãos e rejeição ou quarentena de
duplicidades no processo de carga.

### Resultado esperado

Maior confiabilidade na atribuição de receita por perfil e origem do cliente.

## 7. Período parcial

2027 contém apenas duas transações entre 10 e 25 de janeiro, somando R$ 3.490.
O período não deve ser comparado com anos completos.

Ação: exibir a data de corte e separar períodos abertos de períodos fechados.

Resultado esperado: evitar a leitura de carga parcial como queda de desempenho.

## 8. Uso dos visuais

- **Cards executivos:** resumo global; não respondem ao filtro de região nem à
  seleção dos gráficos de canal e região.
- **Cards regionais:** benchmark global; não respondem ao filtro de região.
- **Gráfico regional:** compara receita e participação por região.
- **Rosca de canais:** compara quantidade de transações, não receita.
- **Evolução trimestral:** mostra receita e média histórica fixa.
- **Matriz produto-região:** identifica concentração de produtos.
- **Tabela trimestral:** mantém referência global e não responde ao filtro ou
  seleção de região.

## 9. Encerramento

O dashboard permite localizar movimentos e problemas de qualidade. As ações
recomendadas não devem partir apenas do valor agregado: primeiro é necessário
validar cobertura de metas, cadastros de clientes, contexto temporal e
completude dos períodos.
