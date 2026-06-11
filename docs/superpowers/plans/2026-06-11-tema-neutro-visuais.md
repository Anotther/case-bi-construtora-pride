# Neutral Dashboard Theme Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Apply the approved neutral theme to every remaining Power BI visual without changing layout, bindings, visual types, or analytical behavior.

**Architecture:** A validation script snapshots each visual contract and asserts the approved palette and container rules. The theme JSON provides global defaults; a focused Node script updates page, report, HTML measure, filters, charts, matrix, and table properties where Power BI theme inheritance is insufficient.

**Tech Stack:** Power BI PBIP, report JSON, TMDL/DAX, Power BI theme JSON, Node.js, PowerShell.

---

### Task 1: Protect the report contract

**Files:**
- Create: `tests/validate-neutral-dashboard-theme.ps1`

- [ ] **Step 1: Write the failing validation**

The test must assert:

```powershell
$expected = @{
    "ae39f2b835ab32a1d092" = "columnChart"
    "1f8e4700b7d9101d683a" = "donutChart"
    "3bf3d02da0a5c6c25019" = "lineStackedColumnComboChart"
    "7fdae38fe736180d922b" = "barChart"
    "a50db6ca0c6445255352" = "pivotTable"
    "26a2d7a119062d88b108" = "tableEx"
}
```

It must verify that positions, dimensions, visual types, and projection
references match a baseline captured before styling. It must also require the
neutral palette, page background, custom theme resource, chart containers,
table/matrix headers, filter styling, and recolored HTML cards.

- [ ] **Step 2: Run the test and verify RED**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File tests/validate-neutral-dashboard-theme.ps1
```

Expected: non-zero exit because the global theme, containers, and neutral HTML
colors are not fully applied.

### Task 2: Create the reusable theme updater

**Files:**
- Create: `scripts/apply-neutral-dashboard-theme.js`
- Modify: `bi-construtura-pride-tema.json`
- Modify: `case-bi-construtora-pride.Report/definition/report.json`
- Modify: `case-bi-construtora-pride.Report/definition/pages/516f47fa1bac5767e01c/page.json`
- Create: `case-bi-construtora-pride.Report/StaticResources/SharedResources/CustomThemes/ConstrutoraPrideNeutral.json`

- [ ] **Step 1: Implement structured JSON helpers**

The Node script must parse JSON, construct Power BI literal expressions, merge
object groups without deleting query/filter definitions, and write formatted
UTF-8 JSON.

- [ ] **Step 2: Expand and install the theme**

Add `visualStyles` defaults for title, background, border, legend, labels,
axes, table, and matrix. Copy the resulting theme into the report resources and
make `report.json` reference `ConstrutoraPrideNeutral`.

- [ ] **Step 3: Apply the page background**

Set the page background to `#FCF7F0` with zero transparency while preserving
the current `1920 x 2300` page contract.

### Task 3: Style filters, charts, matrix, and table

**Files:**
- Modify: the eight non-HTML visual JSON files listed in the design spec.

- [ ] **Step 1: Style the two Smart Filters**

Apply white background, `#EDE8E1` border, rounded corners, neutral title/input
text, and hidden visual headers.

- [ ] **Step 2: Style the four chart visuals**

Apply consistent white containers, neutral titles, labels, legends, axes, grid
lines, and series colors. The combo chart must use `#6B797C` columns and
`#B08D72` line.

- [ ] **Step 3: Style matrix and table**

Apply `#566164` headers with white text, `#FCF7F0` alternating rows,
`#EDE8E1` dividers/totals, and neutral container styling.

### Task 4: Recolor the HTML cards

**Files:**
- Modify: `case-bi-construtora-pride.SemanticModel/definition/tables/Medidas.tmdl`

- [ ] **Step 1: Replace the old card palette**

Within `HTML Cards Executivos`, replace:

```text
#14213E -> #24212E
#EDB013 -> #B08D72
#6B7689 -> #6E5746
#2F9E68 -> #6B797D
#D64550 -> #4D332C
#E6E9F0 -> #EDE8E1
```

Do not modify card content, order, measure references, or layout.

### Task 5: Verify the complete PBIP

**Files:**
- Test: `tests/validate-neutral-dashboard-theme.ps1`
- Test: `tests/validate-html-executive-cards.ps1`

- [ ] **Step 1: Run both structural tests**

Expected: both scripts print `PASS`.

- [ ] **Step 2: Parse all report and theme JSON**

Expected: every JSON file parses without errors.

- [ ] **Step 3: Import the TMDL folder**

Use the Power BI modeler `ImportFromTmdlFolder` operation.

Expected: `success: true`.

- [ ] **Step 4: Review the scoped diff**

Confirm no visual changed type, position, size, binding, filters, or sorting and
that all preexisting worktree changes remain present.

