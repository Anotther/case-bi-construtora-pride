const fs = require("fs");
const path = require("path");

const repoRoot = path.resolve(__dirname, "..");
const visualPath = path.join(
  repoRoot,
  "case-bi-construtora-pride.Report",
  "definition",
  "pages",
  "516f47fa1bac5767e01c",
  "visuals",
  "29606862c6d4d2ebb607",
  "visual.json"
);
const exportPath = path.join(repoRoot, "deneb-farol-corrigido.json");

const visual = JSON.parse(fs.readFileSync(visualPath, "utf8"));
const literal = visual.visual.objects.vega[0].properties.jsonSpec.expr.Literal.Value;
const spec = JSON.parse(literal.slice(1, -1));

const configurableSignals = [
  {
    name: "reportTitle",
    value: "Farol de metas por produto, regiao e trimestre",
  },
  {
    name: "firstColumnTitle",
    value: "PRODUTO | REGIAO | TRIMESTRE",
  },
];

spec.signals = [
  ...configurableSignals,
  ...spec.signals.filter(
    (signal) => !configurableSignals.some(({ name }) => name === signal.name)
  ),
];

const regionExpression =
  'isValid(datum.Regiao) ? datum.Regiao : ' +
  'isValid(datum["REGIÃO"]) ? datum["REGIÃO"] : ' +
  'isValid(datum["REGIÃƒO"]) ? datum["REGIÃƒO"] : ""';
const combinationExpression =
  'datum.Produto + " | " + datum.RegiaoExibicao + " | " + datum.Trimestre';

const rows = spec.data.find((data) => data.name === "rows");
rows.transform = [
  {
    type: "formula",
    as: "RegiaoExibicao",
    expr: regionExpression,
  },
  {
    type: "aggregate",
    groupby: ["Produto", "RegiaoExibicao", "Trimestre"],
  },
  {
    type: "formula",
    as: "Combination",
    expr: combinationExpression,
  },
  {
    type: "collect",
    sort: {
      field: ["Produto", "RegiaoExibicao", "Trimestre"],
      order: ["ascending", "ascending", "ascending"],
    },
  },
  {
    type: "window",
    ops: ["row_number"],
    as: ["rowIndex"],
  },
];

const cells = spec.data.find((data) => data.name === "cells");
cells.transform = [
  {
    type: "formula",
    as: "RegiaoExibicao",
    expr: regionExpression,
  },
  {
    type: "formula",
    as: "Combination",
    expr: combinationExpression,
  },
  {
    type: "lookup",
    from: "rows",
    key: "Combination",
    fields: ["Combination"],
    values: ["rowIndex"],
    as: ["rowIndex"],
  },
  {
    type: "filter",
    expr:
      "isValid(datum.Atingimento) && datum.Ano >= 2023 && datum.Ano <= 2026",
  },
];

const titleMark = spec.marks.find(
  (mark) =>
    mark.type === "text" &&
    mark.encode?.enter?.text?.value ===
      "Farol — meta oficial por combinação e ano"
);
if (!titleMark) {
  throw new Error("Could not locate the report title mark.");
}
titleMark.encode.enter.text = { signal: "reportTitle" };

const firstColumnMark = spec.marks.find(
  (mark) =>
    mark.type === "text" &&
    mark.encode?.enter?.text?.value === "COMBINAÇÃO (META OFICIAL)"
);
if (!firstColumnMark) {
  throw new Error("Could not locate the first-column title mark.");
}
firstColumnMark.encode.enter.text = { signal: "firstColumnTitle" };

visual.visual.objects.vega[0].properties.jsonSpec.expr.Literal.Value =
  `'${JSON.stringify(spec, null, 2)}'`;

fs.writeFileSync(visualPath, `${JSON.stringify(visual, null, 2)}\n`, "utf8");
fs.writeFileSync(exportPath, `${JSON.stringify(spec, null, 2)}\n`, "utf8");

console.log(`Updated ${visualPath}`);
console.log(`Created ${exportPath}`);
