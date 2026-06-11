$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$visualsRoot = Join-Path $repoRoot "case-bi-construtora-pride.Report\definition\pages\516f47fa1bac5767e01c\visuals"
$measuresPath = Join-Path $repoRoot "case-bi-construtora-pride.SemanticModel\definition\tables\Medidas.tmdl"
$expectedVisualId = "8ea21b49662a4d58a8d1"
$cardIds = @(
    "4c5815a55bb0c8101b6b",
    "bb655692b046ca546ace",
    "fb42910a0d9d905535d0",
    "24c429908a2a2eaa5cd9",
    "f9fce7631de990e3b992",
    "36f0beac11387206013e"
)
$errors = [System.Collections.Generic.List[string]]::new()

foreach ($cardId in $cardIds) {
    $cardVisualPath = Join-Path (Join-Path $visualsRoot $cardId) "visual.json"
    if (Test-Path -LiteralPath $cardVisualPath) {
        $errors.Add("Native card visual still exists: $cardId")
    }
}

$htmlVisuals = @(
    Get-ChildItem -LiteralPath $visualsRoot -Directory | ForEach-Object {
        $visualPath = Join-Path $_.FullName "visual.json"
        if (Test-Path -LiteralPath $visualPath) {
            $visual = Get-Content -LiteralPath $visualPath -Raw -Encoding utf8 | ConvertFrom-Json
            if ($visual.visual.visualType -eq "htmlContent443BE3AD55E043BF878BED274D3A6855" -and
                [double]$visual.position.y -eq 90) {
                [pscustomobject]@{
                    Id = $_.Name
                    Json = $visual
                }
            }
        }
    }
)

if ($htmlVisuals.Count -ne 1) {
    $errors.Add("Expected exactly one HTML Content visual at y=90; found $($htmlVisuals.Count).")
}
else {
    $htmlVisual = $htmlVisuals[0]
    if ($htmlVisual.Id -ne $expectedVisualId) {
        $errors.Add("Unexpected HTML visual id: $($htmlVisual.Id)")
    }

    $position = $htmlVisual.Json.position
    $expectedPosition = @{
        x = 52
        y = 90
        width = 1814
        height = 150
    }
    foreach ($property in $expectedPosition.Keys) {
        if ([double]$position.$property -ne [double]$expectedPosition[$property]) {
            $errors.Add("Visual position '$property' is $($position.$property), expected $($expectedPosition[$property]).")
        }
    }

    $projection = $htmlVisual.Json.visual.query.queryState.content.projections[0]
    if ($projection.queryRef -ne "Medidas.HTML Cards Executivos") {
        $errors.Add("HTML visual queryRef is '$($projection.queryRef)'.")
    }
    if ($projection.field.Measure.Property -ne "HTML Cards Executivos") {
        $errors.Add("HTML visual is not bound to the expected measure.")
    }
    if ($htmlVisual.Json.visual.objects.crossFilter[0].properties.enabled.expr.Literal.Value -ne "false") {
        $errors.Add("HTML visual cross-filter must be disabled.")
    }
}

$measures = Get-Content -LiteralPath $measuresPath -Raw -Encoding utf8
$aTilde = [char]0x00E3
$cCedilla = [char]0x00E7
$eAcute = [char]0x00E9
$iAcute = [char]0x00ED
$aTildeUpper = [char]0x00C3
$cCedillaUpper = [char]0x00C7
$eAcuteUpper = [char]0x00C9
$iAcuteUpper = [char]0x00CD
$ticketMedio = "[Ticket M${eAcute}dio]"
$variacaoPct = "[% Varia${cCedilla}${aTilde}o vs LY]"
$variacao = "[Varia${cCedilla}${aTilde}o vs LY]"
$canalLider = "[Canal L${iAcute}der]"
$receitaCanalLider = "[% Receita Canal L${iAcute}der]"
$regiaoLider = "[Regi${aTilde}o L${iAcute}der]"
$receitaRegiaoLider = "[% Receita Regi${aTilde}o L${iAcute}der]"
$regiaoAtencao = "[Regi${aTilde}o Aten${cCedilla}${aTilde}o]"
$receitaRegiaoAtencao = "[% Receita Regi${aTilde}o Aten${cCedilla}${aTilde}o]"
$labelTicketMedio = "TICKET M${eAcuteUpper}DIO"
$labelVariacao = "VARIA${cCedillaUpper}${aTildeUpper}O ANUAL"
$labelCanalLider = "CANAL L${iAcuteUpper}DER"
$labelRegiaoLider = "REGI${aTildeUpper}O L${iAcuteUpper}DER"
$labelRegiaoAtencao = "REGI${aTildeUpper}O DE ATEN${cCedillaUpper}${aTildeUpper}O"
$requiredFragments = @(
    "measure 'HTML Cards Executivos'",
    "[Total Vendas]",
    "[Qtd Vendas]",
    $ticketMedio,
    $variacaoPct,
    $variacao,
    $canalLider,
    $receitaCanalLider,
    $regiaoLider,
    $receitaRegiaoLider,
    $regiaoAtencao,
    $receitaRegiaoAtencao,
    "VENDAS TOTAIS",
    $labelTicketMedio,
    $labelVariacao,
    $labelCanalLider,
    $labelRegiaoLider,
    $labelRegiaoAtencao,
    "#14213E",
    "#EDB013",
    "#6B7689",
    "#2F9E68",
    "#D64550",
    "grid-template-columns:repeat(6,1fr)",
    "border-radius:14px"
)

foreach ($fragment in $requiredFragments) {
    if (-not $measures.Contains($fragment)) {
        $errors.Add("Missing measure fragment: $fragment")
    }
}

if ($errors.Count -gt 0) {
    $errors | ForEach-Object { Write-Host "FAIL: $_" -ForegroundColor Red }
    exit 1
}

Write-Output "PASS: executive HTML cards structure is valid."
