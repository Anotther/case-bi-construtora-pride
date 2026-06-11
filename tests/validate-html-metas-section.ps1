$ErrorActionPreference = "Stop"

function Assert-True {
    param(
        [Parameter(Mandatory = $true)] [bool] $Condition,
        [Parameter(Mandatory = $true)] [string] $Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

function Assert-Equal {
    param(
        [Parameter(Mandatory = $true)] $Actual,
        [Parameter(Mandatory = $true)] $Expected,
        [Parameter(Mandatory = $true)] [string] $Message
    )

    if ($Actual -ne $Expected) {
        throw "$Message Expected '$Expected', got '$Actual'."
    }
}

function Assert-Near {
    param(
        [Parameter(Mandatory = $true)] [double] $Actual,
        [Parameter(Mandatory = $true)] [double] $Expected,
        [Parameter(Mandatory = $true)] [string] $Message,
        [double] $Tolerance = 0.000001
    )

    if ([Math]::Abs($Actual - $Expected) -gt $Tolerance) {
        throw "$Message Expected '$Expected', got '$Actual'."
    }
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$visualPath = Join-Path $repoRoot "case-bi-construtora-pride.Report\definition\pages\516f47fa1bac5767e01c\visuals\29606862c6d4d2ebb607\visual.json"
$reportPath = Join-Path $repoRoot "case-bi-construtora-pride.Report\definition\report.json"
$measuresPath = Join-Path $repoRoot "case-bi-construtora-pride.SemanticModel\definition\tables\Medidas.tmdl"
$htmlGuid = "htmlContent443BE3AD55E043BF878BED274D3A6855"

$visual = Get-Content -Raw -LiteralPath $visualPath | ConvertFrom-Json
$report = Get-Content -Raw -LiteralPath $reportPath | ConvertFrom-Json
$measures = Get-Content -Raw -LiteralPath $measuresPath

Assert-Equal $visual.visual.visualType $htmlGuid "The target visual must use HTML Content."
Assert-Near $visual.position.x 50 "The visual x position changed."
Assert-Near $visual.position.y 1166.6666666666667 "The visual y position changed."
Assert-Near $visual.position.width 1093.3333333333335 "The visual width changed."
Assert-Near $visual.position.height 376.66666666666669 "The visual height changed."

$projections = @($visual.visual.query.queryState.content.projections)
Assert-Equal $projections.Count 1 "HTML Content must receive one HTML measure."
Assert-Equal $projections[0].queryRef "Medidas.HTML Controle Metas" "Unexpected HTML measure binding."

Assert-True (@($report.publicCustomVisuals) -contains $htmlGuid) "The report must declare HTML Content."

foreach ($measureName in @(
    "Vendas Metas Oficiais",
    "Valor Metas Ciclos",
    "% Execução Metas Oficiais",
    "Combinações Meta com Venda",
    "HTML Controle Metas"
)) {
    Assert-True ($measures.Contains("measure '$measureName'")) "Missing measure '$measureName'."
}

foreach ($text in @(
    "Controle das metas oficiais",
    "Cobertura de metas",
    "Execução das metas",
    "Combinações com venda",
    "Sem venda compatível",
    "Atingida",
    "Em andamento"
)) {
    Assert-True ($measures.Contains($text)) "The HTML measure is missing '$text'."
}

Assert-True (-not $visual.visual.visualType.StartsWith("deneb")) "The target visual must no longer be Deneb."

Write-Output "HTML metas section validation passed."
