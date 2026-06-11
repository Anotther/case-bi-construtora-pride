# Executive HTML Cards Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the six native Power BI cards with one filter-responsive HTML Content visual styled as an executive KPI row.

**Architecture:** A DAX measure named `HTML Cards Executivos` generates the complete HTML and CSS using the existing KPI measures. One HTML Content visual binds to that measure and occupies the current card row; the six native card folders are removed only after the structural test proves the replacement contract.

**Tech Stack:** Power BI PBIP, TMDL/DAX, Power BI report JSON, HTML Content custom visual, PowerShell validation.

---

### Task 1: Define the structural contract

**Files:**
- Create: `tests/validate-html-executive-cards.ps1`

- [ ] **Step 1: Write the failing validation**

Create a PowerShell test that:

```powershell
$cardIds = @(
    "4c5815a55bb0c8101b6b",
    "bb655692b046ca546ace",
    "fb42910a0d9d905535d0",
    "24c429908a2a2eaa5cd9",
    "f9fce7631de990e3b992",
    "36f0beac11387206013e"
)
```

The test must assert that all six folders are absent, exactly one HTML Content
visual at `x = 52`, `y = 90`, `width = 1814`, `height = 150` binds to
`Medidas.HTML Cards Executivos`, and `Medidas.tmdl` contains the six labels,
the approved colors, and the dynamic measure references.

- [ ] **Step 2: Run the test and verify RED**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File tests/validate-html-executive-cards.ps1
```

Expected: non-zero exit because the native card folders still exist and the
HTML measure and visual do not exist.

### Task 2: Add the HTML measure and visual

**Files:**
- Modify: `case-bi-construtora-pride.SemanticModel/definition/tables/Medidas.tmdl`
- Create: `case-bi-construtora-pride.Report/definition/pages/516f47fa1bac5767e01c/visuals/8ea21b49662a4d58a8d1/visual.json`

- [ ] **Step 1: Add the DAX measure**

Add `HTML Cards Executivos` to the `Destaques` display folder. It must format:

```dax
[Total Vendas]
[Qtd Vendas]
[Ticket Médio]
[% Variação vs LY]
[Variação vs LY]
[Canal Líder]
[% Receita Canal Líder]
[Região Líder]
[% Receita Região Líder]
[Região Atenção]
[% Receita Região Atenção]
```

The returned HTML must use a six-column CSS grid, white cards, `14px` radius,
`#EDB013` top accent, `#14213E` values, `#6B7689` supporting text, and semantic
green/red supporting text.

- [ ] **Step 2: Add the HTML Content visual**

Create one `htmlContent443BE3AD55E043BF878BED274D3A6855` visual at the exact
card-row dimensions. Disable cross-filter, hyperlinks, selection, visual
background, border, title, subtitle, and header.

- [ ] **Step 3: Run the test and confirm the expected intermediate failure**

Run the validation again.

Expected: non-zero exit only because the six native cards have not yet been
removed.

### Task 3: Replace the native cards

**Files:**
- Delete: the six card `visual.json` files and their now-empty visual folders.

- [ ] **Step 1: Remove only the six approved card folders**

Delete the IDs listed in Task 1. Do not alter slicers, charts, tables, or the
existing HTML metas section.

- [ ] **Step 2: Run the structural validation and verify GREEN**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File tests/validate-html-executive-cards.ps1
```

Expected: `PASS: executive HTML cards structure is valid.`

- [ ] **Step 3: Validate all report JSON**

Run a PowerShell loop that parses every
`case-bi-construtora-pride.Report/definition/**/*.json` with
`ConvertFrom-Json`.

Expected: exit code `0` and a parsed-file count with no errors.

- [ ] **Step 4: Review the scoped diff**

Confirm the implementation diff contains only the measure, new visual, six
card deletions, validation script, and this plan. Existing unrelated worktree
changes must remain untouched.

