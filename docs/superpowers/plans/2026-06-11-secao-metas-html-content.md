# Seção de Metas HTML Content Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Substituir exclusivamente o Deneb da seção de metas por um HTML Content que apresente cobertura, execução e desempenho das cinco metas oficiais.

**Architecture:** Novas medidas DAX calcularão vendas restritas às chaves oficiais, valor recorrente das metas e HTML completo. O visual PBIR manterá o mesmo nome, posição e dimensões, mudando apenas para o GUID informado do HTML Content e vinculando `Medidas[HTML Controle Metas]` ao papel `content`.

**Tech Stack:** Power BI PBIP/PBIR, TMDL, DAX, HTML Content 1.6, HTML5 e CSS.

---

### Task 1: Criar validação estrutural

**Files:**
- Create: `tests/validate-html-metas-section.ps1`
- Test: `case-bi-construtora-pride.SemanticModel/definition/tables/Medidas.tmdl`
- Test: `case-bi-construtora-pride.Report/definition/pages/516f47fa1bac5767e01c/visuals/29606862c6d4d2ebb607/visual.json`
- Test: `case-bi-construtora-pride.Report/definition/report.json`

- [ ] **Step 1: Exigir o visual HTML Content e as novas medidas**

O teste deve verificar:

- GUID `htmlContent443BE3AD55E043BF878BED274D3A6855`;
- posição e dimensões originais;
- papel `content` com `Medidas.HTML Controle Metas`;
- registro em `publicCustomVisuals`;
- medidas `Vendas Metas Oficiais`, `Valor Metas Ciclos`,
  `% Execução Metas Oficiais`, `Combinações Meta com Venda` e
  `HTML Controle Metas`;
- presença dos textos dos três KPIs e dos estados da linha;
- ausência do GUID Deneb no visual-alvo.

- [ ] **Step 2: Executar e confirmar falha**

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/validate-html-metas-section.ps1
```

Expected: falha porque o visual ainda é Deneb.

### Task 2: Criar medidas de negócio e HTML

**Files:**
- Modify: `case-bi-construtora-pride.SemanticModel/definition/tables/Medidas.tmdl`

- [ ] **Step 1: Criar medidas auxiliares**

Adicionar na pasta `Metas`:

```DAX
Vendas Metas Oficiais =
CALCULATE(
    [Total Vendas],
    TREATAS(VALUES(dMetas[CHAVE_META]), fVendas[CHAVE_META])
)
```

`Valor Metas Ciclos` deve multiplicar o valor oficial pela quantidade de anos
selecionados, removendo o efeito de `fVendas` sobre `dMetas`.

`Combinações Meta com Venda` deve contar chaves oficiais cujo valor de
`[Vendas Metas Oficiais]` seja maior que zero.

- [ ] **Step 2: Criar a medida HTML**

`HTML Controle Metas` deve:

- construir sua tabela-base com as cinco linhas de `ALL(dMetas)`;
- calcular vendas e atingimento por chave e anos selecionados;
- concatenar cartões e linhas com `CONCATENATEX`;
- usar CSS inline dentro de `<style>`;
- mostrar `Sem venda compatível` para valores vazios;
- limitar a largura visual da barra a 100%;
- preservar o percentual real no texto.

### Task 3: Converter o visual

**Files:**
- Modify: `case-bi-construtora-pride.Report/definition/pages/516f47fa1bac5767e01c/visuals/29606862c6d4d2ebb607/visual.json`
- Modify: `case-bi-construtora-pride.Report/definition/report.json`

- [ ] **Step 1: Trocar o tipo do visual**

Usar `htmlContent443BE3AD55E043BF878BED274D3A6855` e preservar
`x`, `y`, `z`, `width`, `height` e `tabOrder`.

- [ ] **Step 2: Vincular a medida**

Configurar `queryState.content.projections` com
`Medidas[HTML Controle Metas]`.

- [ ] **Step 3: Configurar renderização**

Definir `contentFormatting.format = html`, ocultar título, borda e cabeçalho do
contêiner e manter fundo transparente para o próprio HTML controlar o cartão.

- [ ] **Step 4: Registrar o visual**

Adicionar o GUID do HTML Content em `report.json.publicCustomVisuals`. Remover o
GUID do Deneb somente se nenhum outro visual do relatório o utilizar.

### Task 4: Validar

**Files:**
- Test: arquivos alterados nas tarefas anteriores.

- [ ] **Step 1: Executar validação específica**

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/validate-html-metas-section.ps1
```

Expected: `HTML metas section validation passed.`

- [ ] **Step 2: Validar JSON e referências**

```powershell
Get-ChildItem case-bi-construtora-pride.Report -Recurse -Filter *.json |
  ForEach-Object { Get-Content -Raw -LiteralPath $_.FullName | ConvertFrom-Json | Out-Null }
```

Expected: exit code `0`.

- [ ] **Step 3: Confirmar escopo**

```powershell
git diff --check
git diff --stat
```

Expected: somente medidas, visual-alvo, registro do visual, teste e plano.

- [ ] **Step 4: Abrir o PBIP**

Confirmar no Power BI Desktop que o HTML Content carrega a medida, mostra cinco
combinações e não altera nenhum outro visual.
