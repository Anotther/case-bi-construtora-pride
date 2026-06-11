# Guia rápido — Dashboard Power BI (Case Construtora Pride)

Roteiro enxuto: transformações → modelo → medidas → visuais. Tempo estimado: 2–3h.

---

## 1. Importar (Obter Dados > Excel)

| Tabela no modelo | Arquivo | Papel |
|---|---|---|
| `fVendas` | Base_Vendas_Detalhada.xlsx | Fato |
| `dClientes` | Base_Clientes_Detalhada.xlsx | Dimensão |
| `dMetas` | Base_Metas.xlsx | Dimensão/fato de meta |

---

## 2. Transformações no Power Query (por tabela)

### 2.1 Criar tabela De-Para de regiões (fazer PRIMEIRO)
As 3 bases usam 3 grafias diferentes. Criar tabela manual (Página Inicial > Inserir Dados):

| Origem | Padrão |
|---|---|
| South / SUL / Sul | Sul |
| North / NORTE / Norte | Norte |
| East / LESTE / Leste | Leste |
| West / OESTE / Oeste | Oeste |
| Central / CENTRAL / Central | Central |

> Alternativa mais rápida: em vez de De-Para, tratar direto em cada tabela (passos abaixo). O De-Para é o que você **menciona na apresentação** como solução escalável.

### 2.2 `fVendas`
1. Tipos: DATA → Data; VALOR_VENDA → Número inteiro.
2. REGIÃO já está no padrão (Sul, Norte…) — **nenhuma mudança**.
3. Coluna nova **TRIMESTRE**: Adicionar Coluna > Coluna Personalizada → `"Q" & Text.From(Date.QuarterOfYear([DATA]))`.
4. Coluna nova **ANO**: `Date.Year([DATA])`.

### 2.3 `dClientes` (a tabela problemática)
1. REGIÃO está em **inglês** → Transformar > Substituir Valores (South→Sul, North→Norte, East→Leste, West→Oeste; Central fica).
2. **Deduplicar**: Agrupar Por `ID_CLIENTE` com agregações:
   - `QTD_CADASTROS` = Contar Linhas
   - `NOME_CLIENTE` = usar Todas as Linhas e depois `Text.Combine([Detalhes][NOME_CLIENTE], " / ")`
   - Resultado: 202 = "Jaqueline / Caetano / Caio", 1 linha por ID.
3. Coluna **TIPO_CADASTRO**: `if [QTD_CADASTROS] > 1 then "Duplicado" else "OK"`.
4. **Órfãos**: Página Inicial > Acrescentar Consulta com tabela manual de 4 linhas:
   - IDs 200, 201, 205, 207 · NOME = "Cliente não identificado" · TIPO_CADASTRO = "Não identificado".
5. Onde categoria/região conflitam (duplicados), deixar "Indefinido" — **não inventar**.

### 2.4 `dMetas`
1. REGIÃO está em **CAIXA ALTA** → Transformar > Formato > Capitalizar Cada Palavra (SUL→Sul).
2. TRIMESTRE está como **T1–T4** → Substituir Valores: T→Q (vira Q1–Q4, igual à fVendas).
3. Coluna **CHAVE_META**: `Text.From([PRODUTO_ID]) & "|" & [REGIÃO] & "|" & [TRIMESTRE]`.
4. Criar a **mesma chave na fVendas**: `Text.From([ID_PRODUTO]) & "|" & [REGIÃO] & "|" & [TRIMESTRE]`.
   > A meta não tem ANO — premissa documentada: meta recorrente a cada ano.

### 2.5 `dCalendario`
No Power BI (não no Power Query), Nova Tabela:
```dax
dCalendario = ADDCOLUMNS(CALENDARAUTO(),
  "Ano", YEAR([Date]),
  "Trimestre", "Q" & FORMAT([Date],"Q"),
  "AnoTri", YEAR([Date]) & " Q" & FORMAT([Date],"Q"),
  "Mês", FORMAT([Date],"MMM/YY"))
```

---

## 3. Modelo (Exibição de Modelo)

| Relação | Cardinalidade |
|---|---|
| dClientes[ID_CLIENTE] → fVendas[ID_CLIENTE] | 1:N |
| dCalendario[Date] → fVendas[DATA] | 1:N |
| dMetas[CHAVE_META] → fVendas[CHAVE_META] | 1:N |

Marcar dCalendario como Tabela de Data.

---

## 4. Medidas DAX (copiar e colar)

```dax
Total Vendas = SUM(fVendas[VALOR_VENDA])
Total Meta = SUM(dMetas[META_VENDAS])
% Atingimento = DIVIDE([Total Vendas], [Total Meta])
Qtd Vendas = COUNTROWS(fVendas)
Ticket Médio = AVERAGE(fVendas[VALOR_VENDA])
Cobertura de Metas = DIVIDE(COUNTROWS(dMetas), 50)   // 10 produtos x 5 regiões
Vendas LY = CALCULATE([Total Vendas], DATEADD(dCalendario[Date], -1, YEAR))
Média Trimestral Hist = DIVIDE(CALCULATE([Total Vendas], ALL(dCalendario)), 16)
% vs Média Hist = DIVIDE([Total Vendas], [Média Trimestral Hist])
% Receita Não Identificada = DIVIDE(
  CALCULATE([Total Vendas], dClientes[TIPO_CADASTRO] = "Não identificado"),
  [Total Vendas])
```

---

## 5. Visuais (replicando o HTML, 1 página, ordem topo→baixo)

| # | Visual do HTML | Visual Power BI | Campos |
|---|---|---|---|
| 1 | Cartões KPI | 6 Cartões | Total Vendas · Total Meta · % Atingimento · Cobertura de Metas · % Receita Não Identificada |
| 2 | Vendas por região | Colunas clusterizadas | Eixo: fVendas[REGIÃO] · Valor: Total Vendas |
| 3 | Mix por canal | Rosca | Legenda: CANAL_VENDA · Valor: Total Vendas |
| 4 | Trimestral + média | Colunas + linha | Eixo: dCalendario[AnoTri] · Colunas: Total Vendas · Linha: Média Trimestral Hist |
| 5 | Farol de metas | **Matriz** | Linhas: dMetas (produto+região+tri) · Colunas: Ano · Valor: % Atingimento · **Formatação condicional de fundo**: ≥1 verde, 0,7–0,99 âmbar, <0,7 vermelho |
| 6 | Receita por produto | Barras horizontais | Eixo: ID_PRODUTO · Valor: Total Vendas |
| 7 | Mapa produto×região | Matriz | Linhas: ID_PRODUTO · Colunas: REGIÃO · Valor: Total Vendas · escala de cor |
| 8 | Tabela trimestral | Tabela + **2 Segmentações** (Ano, Região) | AnoTri · Total Vendas · % vs Média Hist |

Tema: Exibição > Temas > Personalizar — primária `#14213E` (navy), secundária `#EDB013` (dourado), fundo `#F6F7FA`.

---

## 6. O que falar na apresentação (30 segundos cada)

1. **3 grafias de região** → De-Para no Power Query (mostra a tabela).
2. **Clientes duplicados + órfãos** → "Sobram 4 cadastros duplicados e faltam 4 IDs nas vendas — testei a hipótese de serem os mesmos clientes via aderência por região; os dados não confirmam. Mantive 'não identificado' (39% da receita), documentei e deixei como pergunta à área de cadastro."
3. **Metas incompletas** → cobertura de 10% (5 de 50 combinações), sem ano; premissa de recorrência anual documentada; recomendação nº 1: completar a matriz de metas.
4. **Insights**: Sul lidera (27%), Leste crítico (3 produtos sem venda), Online 43%, queda de 26% em 2026.

## Checklist final
- [ ] Nenhum visual com (Blank) inesperado
- [ ] Total Vendas do painel = R$ 277.697 (se inflar, o join de clientes duplicou linhas)
- [ ] Slicers de Ano e Região funcionando na tabela
- [ ] Título do relatório + nota de premissa das metas visível
