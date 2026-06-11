$ErrorActionPreference = "Stop"

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

function Assert-True {
    param(
        [Parameter(Mandatory = $true)] [bool] $Condition,
        [Parameter(Mandatory = $true)] [string] $Message
    )

    if (-not $Condition) {
        throw $Message
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
$exportSpecPath = Join-Path $repoRoot "deneb-farol-corrigido.json"
$denebGuid = "deneb7E15AEF80B9E4D4F8E12924291ECE89A"

$visual = Get-Content -Raw -LiteralPath $visualPath | ConvertFrom-Json
$report = Get-Content -Raw -LiteralPath $reportPath | ConvertFrom-Json

Assert-Equal $visual.visual.visualType $denebGuid "The target visual must use the certified Deneb visual type."
Assert-Near $visual.position.x 50 "The visual x position changed."
Assert-Near $visual.position.y 1166.6666666666667 "The visual y position changed."
Assert-Near $visual.position.width 1093.3333333333335 "The visual width changed."
Assert-Near $visual.position.height 376.66666666666669 "The visual height changed."

$projections = @($visual.visual.query.queryState.dataset.projections)
Assert-Equal $projections.Count 6 "The Deneb dataset must contain the five display fields and the row-preservation measure."

$expectedFields = @(
    @{ QueryRef = "dMetas.PRODUTO_ID"; DisplayName = "Produto" },
    @{ QueryRef = "dMetas.REGIÃO"; DisplayName = "Regiao" },
    @{ QueryRef = "dMetas.TRIMESTRE"; DisplayName = "Trimestre" },
    @{ QueryRef = "dCalendario.Ano"; DisplayName = "Ano" },
    @{ QueryRef = "Medidas.% Atingimento"; DisplayName = "Atingimento" },
    @{ QueryRef = "Medidas.Linha Farol"; DisplayName = "LinhaFarol" }
)

foreach ($expected in $expectedFields) {
    $projection = $projections | Where-Object { $_.queryRef -eq $expected.QueryRef }
    Assert-True ($null -ne $projection) "Missing dataset projection '$($expected.QueryRef)'."
    Assert-Equal $projection.displayName $expected.DisplayName "Unexpected display name for '$($expected.QueryRef)'."
}

$specLiteral = $visual.visual.objects.vega[0].properties.jsonSpec.expr.Literal.Value
Assert-True ($specLiteral.StartsWith("'") -and $specLiteral.EndsWith("'")) "Deneb jsonSpec must be wrapped as a PBIR text literal."
$specText = $specLiteral.Substring(1, $specLiteral.Length - 2)
$spec = $specText | ConvertFrom-Json

Assert-Equal $spec.'$schema' "https://vega.github.io/schema/vega/v5.json" "The visual must use the Vega 5 schema."
Assert-True (@($spec.data | Where-Object { $_.name -eq "dataset" }).Count -eq 1) "The Vega spec must bind to the Deneb dataset."

foreach ($year in 2023, 2024, 2025, 2026) {
    Assert-True ($specText.Contains([string] $year)) "The Vega specification must include the year $year."
}

foreach ($color in "#E3F3ED", "#FFF1CF", "#FDE7E9", "#1B7F5A", "#A66A00", "#D64550") {
    Assert-True ($specText.Contains($color)) "The Vega specification is missing conditional color $color."
}

Assert-True ($specText.Contains("isValid(datum.Atingimento)")) "The Vega specification must suppress marks for blank attainment values."
Assert-True ($specText.Contains("datum.Atingimento >= 1")) "The Vega specification must define the green threshold."
Assert-True ($specText.Contains("datum.Atingimento >= 0.7")) "The Vega specification must define the amber threshold."
Assert-True ($specText.Contains('format(datum.Atingimento, \".0%\")')) "The Vega specification must format attainment as integer percentages."
Assert-True ($specText.Contains('"name": "reportTitle"')) "The Vega specification must expose an editable report title signal."
Assert-True ($specText.Contains('"name": "firstColumnTitle"')) "The Vega specification must expose an editable first-column title signal."

$measuresText = Get-Content -Raw -LiteralPath $measuresPath
Assert-True ($measuresText.Contains("measure 'Linha Farol' = 1")) "The semantic model must include the row-preservation measure."

Assert-True (Test-Path -LiteralPath $exportSpecPath) "The corrected standalone Deneb JSON must be exported."
$exportSpec = Get-Content -Raw -LiteralPath $exportSpecPath | ConvertFrom-Json
Assert-Equal $exportSpec.'$schema' "https://vega.github.io/schema/vega/v5.json" "The exported Deneb code must use Vega 5."
Assert-True (@($exportSpec.signals | Where-Object { $_.name -eq "reportTitle" }).Count -eq 1) "The exported code must expose reportTitle."
Assert-True (@($exportSpec.signals | Where-Object { $_.name -eq "firstColumnTitle" }).Count -eq 1) "The exported code must expose firstColumnTitle."

Assert-True (@($report.publicCustomVisuals) -contains $denebGuid) "The report must declare the certified Deneb visual."

Write-Output "Deneb visual validation passed."
