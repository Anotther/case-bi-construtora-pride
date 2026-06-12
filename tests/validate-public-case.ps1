$ErrorActionPreference = 'Stop'

$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

function Assert-True([bool]$Condition, [string]$Message) {
    if (-not $Condition) {
        throw $Message
    }
}

$requiredFiles = @(
    'README.md',
    'docs/modelo-power-bi.md',
    'assets/dashboard-overview.png',
    'LICENSE'
)

foreach ($relativePath in $requiredFiles) {
    $fullPath = Join-Path $root $relativePath
    Assert-True (Test-Path -LiteralPath $fullPath -PathType Leaf) "Arquivo obrigatorio ausente: $relativePath"
}

$readmePath = Join-Path $root 'README.md'
$readmeContent = Get-Content -LiteralPath $readmePath -Raw -Encoding UTF8
$requiredReadmeTexts = @(
    'Decisoes tecnicas',
    'Hipoteses para validacao',
    'Modelo de dados',
    '```mermaid',
    'docs/modelo-power-bi.md',
    'dados sinteticos'
)

foreach ($requiredText in $requiredReadmeTexts) {
    Assert-True ($readmeContent.Contains($requiredText)) "README.md nao contem o texto obrigatorio: $requiredText"
}

$semanticModelDefinition = Join-Path $root 'case-bi-construtora-pride.SemanticModel\definition'
$modelPath = Join-Path $semanticModelDefinition 'model.tmdl'
$relationshipsPath = Join-Path $semanticModelDefinition 'relationships.tmdl'
$expressionsPath = Join-Path $semanticModelDefinition 'expressions.tmdl'

foreach ($tmdlPath in @($modelPath, $relationshipsPath, $expressionsPath)) {
    Assert-True (Test-Path -LiteralPath $tmdlPath -PathType Leaf) "Arquivo TMDL obrigatorio ausente: $tmdlPath"
}

$modelContent = Get-Content -LiteralPath $modelPath -Raw -Encoding UTF8
$relationshipsContent = Get-Content -LiteralPath $relationshipsPath -Raw -Encoding UTF8
$expressionsContent = Get-Content -LiteralPath $expressionsPath -Raw -Encoding UTF8
$modelMetadataContent = $modelContent + "`n" + $relationshipsContent + "`n" + $expressionsContent

Assert-True ($modelContent -match '__PBI_TimeIntelligenceEnabled\s*=\s*0') '__PBI_TimeIntelligenceEnabled deve ser 0.'
Assert-True ($modelMetadataContent -notmatch 'DateTableTemplate|LocalDateTable') 'O modelo nao pode conter DateTableTemplate ou LocalDateTable.'
Assert-True ($expressionsContent -match "(?m)^\s*expression\s+'?PastaFontes'?\s*=") 'expressions.tmdl deve declarar expression PastaFontes.'
Assert-True ($relationshipsContent -notmatch '(?i)\bbothDirections\b') 'relationships.tmdl nao pode conter bothDirections.'

$relationshipCount = ([regex]::Matches($relationshipsContent, '(?m)^relationship\b')).Count
Assert-True ($relationshipCount -eq 3) "relationships.tmdl deve conter exatamente 3 linhas iniciadas por relationship; encontrado: $relationshipCount"

$sourceTables = @('fVendas', 'dClientes', 'dMetas')
foreach ($tableName in $sourceTables) {
    $tablePath = Join-Path $semanticModelDefinition "tables\$tableName.tmdl"
    Assert-True (Test-Path -LiteralPath $tablePath -PathType Leaf) "Tabela TMDL obrigatoria ausente: $tableName"
    $tableContent = Get-Content -LiteralPath $tablePath -Raw -Encoding UTF8
    Assert-True ($tableContent -match '\bPastaFontes\b') "$tableName.tmdl deve referenciar PastaFontes."
}

$trackedFiles = @(& git -C $root ls-files)
Assert-True ($LASTEXITCODE -eq 0) 'git ls-files falhou.'

$forbiddenTrackedFiles = @(
    $trackedFiles | Where-Object {
        $_ -match '(^|/)\.pbi/' -or
        $_ -match '(^|/)\.claude/settings\.local\.json$'
    }
)

Assert-True ($forbiddenTrackedFiles.Count -eq 0) (
    "Arquivos locais nao podem estar rastreados:`n" +
    ($forbiddenTrackedFiles -join "`n")
)

$personalPathPattern = 'C:' + '\' + 'Users' + '\'
$personalNamePattern = 'leo' + 'na'
$previousErrorActionPreference = $ErrorActionPreference
try {
    $ErrorActionPreference = 'Continue'
    $personalPathMatches = @(
        & git -C $root grep -n -I -i -F `
            -e $personalPathPattern `
            -e $personalNamePattern `
            -- . ':(exclude)docs/superpowers/**' 2>&1
    )
    $gitGrepExitCode = $LASTEXITCODE
}
finally {
    $ErrorActionPreference = $previousErrorActionPreference
}

if ($gitGrepExitCode -eq 0) {
    Assert-True $false (
        "Dados pessoais encontrados fora de docs/superpowers/**:`n" +
        ($personalPathMatches -join "`n")
    )
}

Assert-True ($gitGrepExitCode -eq 1) "git grep falhou com exit code $gitGrepExitCode."

$reportRoot = Join-Path $root 'case-bi-construtora-pride.Report'
$themePath = Join-Path $root 'bi-construtura-pride-tema.json'
Assert-True (Test-Path -LiteralPath $reportRoot -PathType Container) 'Diretorio do relatorio ausente.'
Assert-True (Test-Path -LiteralPath $themePath -PathType Leaf) 'Arquivo de tema ausente: bi-construtura-pride-tema.json'

$jsonFiles = @(
    Get-ChildItem -LiteralPath $reportRoot -Recurse -File -Filter '*.json'
)
$jsonFiles += Get-Item -LiteralPath $themePath

foreach ($jsonFile in @($jsonFiles | Sort-Object -Property FullName -Unique)) {
    try {
        Get-Content -LiteralPath $jsonFile.FullName -Raw -Encoding UTF8 | ConvertFrom-Json | Out-Null
    }
    catch {
        throw "JSON invalido: $($jsonFile.FullName). $($_.Exception.Message)"
    }
}

$measuresPath = Join-Path $semanticModelDefinition 'tables\Medidas.tmdl'
$modelDocumentationPath = Join-Path $root 'docs\modelo-power-bi.md'
$measurePattern = "^\s*measure\s+(?:'(?<quoted>(?:[^']|'')+)'|(?<unquoted>[^\s=]+))\s*="
$measureNames = @(
    foreach ($line in Get-Content -LiteralPath $measuresPath -Encoding UTF8) {
        $measureMatch = [regex]::Match($line, $measurePattern)
        if ($measureMatch.Success) {
            if ($measureMatch.Groups['quoted'].Success) {
                $measureMatch.Groups['quoted'].Value.Replace("''", "'")
            }
            else {
                $measureMatch.Groups['unquoted'].Value
            }
        }
    }
) | Sort-Object -Unique

Assert-True ($measureNames.Count -gt 0) 'Nenhuma medida foi encontrada em Medidas.tmdl.'

$modelDocumentationContent = Get-Content -LiteralPath $modelDocumentationPath -Raw -Encoding UTF8
foreach ($measureName in $measureNames) {
    Assert-True ($modelDocumentationContent.Contains($measureName)) "Medida ausente em docs/modelo-power-bi.md: $measureName"
}

Write-Host 'Validacao publica concluida com sucesso.'
