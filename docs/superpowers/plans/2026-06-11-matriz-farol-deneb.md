# Matriz Farol Deneb Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Converter a matriz existente em um visual Deneb no mesmo lugar, preservando os campos atuais e aplicando o estilo de tabela com percentuais em pílulas condicionais.

**Architecture:** O arquivo PBIR do visual será convertido de `pivotTable` para o GUID certificado do Deneb. Os cinco campos existentes serão remapeados para o papel único `dataset`, com nomes de exibição estáveis, e uma especificação Vega embutida desenhará cabeçalho, linhas, rótulos, anos e pílulas sem alterar o modelo semântico.

**Tech Stack:** Power BI Project (PBIP/PBIR), Deneb 1.9+, Vega 5, PowerShell, JSON.

---

### Task 1: Criar a validação estrutural

**Files:**
- Create: `tests/validate-deneb-visual.ps1`
- Test: `case-bi-construtora-pride.Report/definition/pages/516f47fa1bac5767e01c/visuals/29606862c6d4d2ebb607/visual.json`

- [ ] **Step 1: Escrever o teste que exige a conversão para Deneb**

O script deve carregar o visual, exigir o GUID
`deneb7E15AEF80B9E4D4F8E12924291ECE89A`, validar o papel `dataset`, analisar o
`jsonSpec` como JSON e conferir posição, campos, faixas de cor e tratamento de
valores vazios.

- [ ] **Step 2: Executar o teste e confirmar a falha**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/validate-deneb-visual.ps1
```

Expected: falha informando que o tipo atual é `pivotTable`.

- [ ] **Step 3: Commitar a validação**

```powershell
git add tests/validate-deneb-visual.ps1
git commit -m "test: validate Deneb farol visual"
```

### Task 2: Converter o visual para Deneb

**Files:**
- Modify: `case-bi-construtora-pride.Report/definition/pages/516f47fa1bac5767e01c/visuals/29606862c6d4d2ebb607/visual.json`
- Modify: `case-bi-construtora-pride.Report/definition/report.json`

- [ ] **Step 1: Remapear os campos para o papel dataset**

Preservar `PRODUTO_ID`, `REGIÃO`, `TRIMESTRE`, `Ano` e `% Atingimento`, com os
nomes de exibição `Produto`, `Regiao`, `Trimestre`, `Ano` e `Atingimento`.

- [ ] **Step 2: Inserir a especificação Vega**

A especificação deve usar `data: [{"name": "dataset"}]`, gerar uma chave de
combinação por linha, criar cabeçalho fixo para `2023`, `2024`, `2025` e `2026`,
e desenhar:

- fundo branco;
- título de coluna em azul-escuro;
- linhas horizontais claras;
- rótulos em azul-escuro e negrito;
- pílula verde para `Atingimento >= 1`;
- pílula amarela para `0.7 <= Atingimento < 1`;
- pílula vermelha para `Atingimento < 0.7`;
- nenhuma marca ou texto quando `Atingimento` for vazio.

- [ ] **Step 3: Registrar o visual público certificado**

Adicionar `deneb7E15AEF80B9E4D4F8E12924291ECE89A` em
`report.json.publicCustomVisuals`, preservando o Smart Filter existente.

- [ ] **Step 4: Executar a validação e confirmar sucesso**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/validate-deneb-visual.ps1
```

Expected: `Deneb visual validation passed.`

### Task 3: Validar o projeto PBIP

**Files:**
- Test: `case-bi-construtora-pride.Report/definition/**/*.json`
- Test: `case-bi-construtora-pride.SemanticModel/definition/tables/*.tmdl`

- [ ] **Step 1: Validar todos os JSON do relatório**

Run:

```powershell
Get-ChildItem case-bi-construtora-pride.Report -Recurse -Filter *.json |
  ForEach-Object { Get-Content -Raw -LiteralPath $_.FullName | ConvertFrom-Json | Out-Null }
```

Expected: exit code `0`, sem erros.

- [ ] **Step 2: Confirmar referências no modelo**

Run:

```powershell
rg -n "column (PRODUTO_ID|REGI|TRIMESTRE|Ano)|measure '% Atingimento'" case-bi-construtora-pride.SemanticModel/definition
```

Expected: os cinco campos referenciados são encontrados.

- [ ] **Step 3: Revisar o diff**

Run:

```powershell
git diff --check
git diff --stat
git status --short
```

Expected: sem erros de whitespace; somente plano, teste, visual e `report.json`
fazem parte desta implementação.

- [ ] **Step 4: Commitar a implementação**

```powershell
git add docs/superpowers/plans/2026-06-11-matriz-farol-deneb.md tests/validate-deneb-visual.ps1 case-bi-construtora-pride.Report/definition/pages/516f47fa1bac5767e01c/visuals/29606862c6d4d2ebb607/visual.json case-bi-construtora-pride.Report/definition/report.json
git commit -m "feat: replace target matrix with Deneb farol"
```

### Task 4: Validação visual manual

**Files:**
- Open: `case-bi-construtora-pride.pbip`

- [ ] **Step 1: Abrir o projeto no Power BI Desktop**

Confirmar que o Power BI recupera o Deneb certificado do AppSource e que o
visual abre sem solicitar reparo da definição.

- [ ] **Step 2: Conferir a renderização**

Confirmar posição e tamanho originais, quatro colunas anuais, percentuais
centralizados, faixas de cor corretas e células vazias sem `0%`.

- [ ] **Step 3: Registrar limitações de validação**

Se a abertura do Power BI Desktop não puder ser automatizada, informar
explicitamente que a estrutura PBIR e a especificação Vega foram validadas, mas
que a conferência visual final depende da abertura local pelo usuário.
