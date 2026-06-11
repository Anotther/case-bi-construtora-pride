# Product Region HTML Matrix Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix the invalid PBIP container properties and replace the native product-region matrix with a dynamic HTML table showing revenue and each region's share of the product total.

**Architecture:** A PowerShell contract test detects invalid schema properties and verifies the HTML matrix structure. A DAX measure generates dynamic region columns and product rows; the existing matrix visual is converted in place to HTML Content while preserving its position and dimensions.

**Tech Stack:** Power BI PBIP, TMDL/DAX, HTML Content custom visual, PowerShell, Node.js.

---

### Task 1: Define the regression contract

**Files:**
- Create: `tests/validate-product-region-html.ps1`

- [ ] **Step 1: Write the failing test**

The test must assert:

- no visual has `visualContainerObjects.shadow`;
- title and subtitle entries do not have `properties.color`;
- `scripts/apply-neutral-dashboard-theme.js` does not generate those fields;
- visual `a50db6ca0c6445255352` is HTML Content at
  `1037.5, 1150, 827.5, 455`;
- the visual binds to `Medidas.HTML Vendas Produto Regiao`;
- the measure contains dynamic product/region iteration, R$ values, product
  percentages, left product alignment, centered numeric cells, and total row.

- [ ] **Step 2: Run the test and verify RED**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File tests/validate-product-region-html.ps1
```

Expected: failure for invalid schema fields and missing HTML matrix.

### Task 2: Fix invalid container properties

**Files:**
- Modify: `scripts/apply-neutral-dashboard-theme.js`
- Modify: affected `visual.json` files under the report page.

- [ ] **Step 1: Remove invalid generation**

Delete the `shadow` container block from `applyContainer`. Stop writing `color`
inside title and subtitle container properties; rely on the custom theme for
those colors.

- [ ] **Step 2: Remove invalid persisted properties**

Run the corrected updater or a focused cleanup that removes only those invalid
properties while preserving all other formatting, queries, filters, and layout.

- [ ] **Step 3: Run the test**

Expected: schema assertions pass; matrix assertions remain RED.

### Task 3: Add the dynamic HTML measure

**Files:**
- Modify: `case-bi-construtora-pride.SemanticModel/definition/tables/Medidas.tmdl`

- [ ] **Step 1: Add `HTML Vendas Produto Regiao`**

The DAX must use visible products and regions, remove only the region filter for
the product denominator, sort products by total revenue descending, and build:

```html
<th class="product">Produto</th>
<th class="region">...</th>
<th class="total">Total</th>
```

Each region cell must contain the formatted currency value and a smaller
`0.0% do produto` label. The final row must show regional totals and each
region's share of the grand total.

- [ ] **Step 2: Import the TMDL folder**

Expected: Power BI modeler returns `success: true`.

### Task 4: Convert the matrix visual in place

**Files:**
- Modify: `case-bi-construtora-pride.Report/definition/pages/516f47fa1bac5767e01c/visuals/a50db6ca0c6445255352/visual.json`

- [ ] **Step 1: Replace the visual definition**

Keep name, position, z-order, size, and tab order. Change the visual type to
HTML Content, bind only the new measure, disable cross-filter and hyperlinks,
and hide native container chrome.

- [ ] **Step 2: Run the regression test and verify GREEN**

Expected: `PASS: product-region HTML matrix and PBIP schema are valid.`

### Task 5: Verify the complete report

**Files:**
- Test: `tests/validate-product-region-html.ps1`
- Test: `tests/validate-neutral-dashboard-theme.ps1`
- Test: `tests/validate-html-executive-cards.ps1`

- [ ] **Step 1: Run all structural tests**

Expected: all three scripts print `PASS`.

- [ ] **Step 2: Parse every report and theme JSON**

Expected: no JSON parsing errors.

- [ ] **Step 3: Import the final TMDL folder**

Expected: `success: true`.

- [ ] **Step 4: Confirm Power BI remains closed**

Expected: no `PBIDesktop` process before visual review.

