$ErrorActionPreference = 'Stop'

$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

function Assert-True([bool]$Condition, [string]$Message) {
    if (-not $Condition) {
        throw $Message
    }
}

function Test-BytePattern([byte[]]$Bytes, [byte[]]$Pattern) {
    if ($Pattern.Length -eq 0 -or $Bytes.Length -lt $Pattern.Length) {
        return $false
    }

    $lastStart = $Bytes.Length - $Pattern.Length
    for ($start = 0; $start -le $lastStart; $start++) {
        $firstByte = $Bytes[$start]
        $firstPatternByte = $Pattern[0]
        if ($firstByte -ge 0x41 -and $firstByte -le 0x5A) {
            $firstByte += 0x20
        }
        if ($firstPatternByte -ge 0x41 -and $firstPatternByte -le 0x5A) {
            $firstPatternByte += 0x20
        }
        if ($firstByte -ne $firstPatternByte) {
            continue
        }

        $isMatch = $true
        for ($offset = 1; $offset -lt $Pattern.Length; $offset++) {
            $currentByte = $Bytes[$start + $offset]
            $currentPatternByte = $Pattern[$offset]
            if ($currentByte -ge 0x41 -and $currentByte -le 0x5A) {
                $currentByte += 0x20
            }
            if ($currentPatternByte -ge 0x41 -and $currentPatternByte -le 0x5A) {
                $currentPatternByte += 0x20
            }
            if ($currentByte -ne $currentPatternByte) {
                $isMatch = $false
                break
            }
        }

        if ($isMatch) {
            return $true
        }
    }

    return $false
}

function Assert-NoPersonalBytes([byte[]]$Bytes, [object[]]$BytePatterns, [string]$Location) {
    foreach ($bytePattern in $BytePatterns) {
        if (Test-BytePattern $Bytes $bytePattern.Bytes) {
            throw "Dados pessoais encontrados em $Location ($($bytePattern.Encoding))."
        }
    }
}

function Test-ZipSignature([byte[]]$Bytes) {
    if ($Bytes.Length -lt 4 -or $Bytes[0] -ne 0x50 -or $Bytes[1] -ne 0x4B) {
        return $false
    }

    return (
        ($Bytes[2] -eq 0x03 -and $Bytes[3] -eq 0x04) -or
        ($Bytes[2] -eq 0x05 -and $Bytes[3] -eq 0x06) -or
        ($Bytes[2] -eq 0x07 -and $Bytes[3] -eq 0x08)
    )
}

function Test-ExcludedTextPath([string]$RelativePath) {
    $normalizedPath = $RelativePath.Replace('\', '/')
    return (
        $normalizedPath -match '(^|/)\.git(/|$)' -or
        $normalizedPath -match '^docs/superpowers(/|$)' -or
        $normalizedPath -match '^case-bi-construtora-pride\.SemanticModel/definition/tables/(fVendas|dClientes|dMetas)\.tmdl$' -or
        $normalizedPath -match '(^|/)\.pbi(/|$)' -or
        $normalizedPath -match '(^|/)\.claude(/|$)'
    )
}

function Get-TextFileContent([string]$Path) {
    $bytes = [System.IO.File]::ReadAllBytes($Path)
    if ($bytes.Length -eq 0) {
        return [pscustomobject]@{
            IsText = $true
            Content = ''
        }
    }

    if ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE) {
        return [pscustomobject]@{
            IsText = $true
            Content = [System.Text.Encoding]::Unicode.GetString($bytes, 2, $bytes.Length - 2)
        }
    }

    if ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFE -and $bytes[1] -eq 0xFF) {
        return [pscustomobject]@{
            IsText = $true
            Content = [System.Text.Encoding]::BigEndianUnicode.GetString($bytes, 2, $bytes.Length - 2)
        }
    }

    if ($bytes -contains 0) {
        return [pscustomobject]@{
            IsText = $false
            Content = $null
        }
    }

    try {
        $strictUtf8 = New-Object System.Text.UTF8Encoding($false, $true)
        return [pscustomobject]@{
            IsText = $true
            Content = $strictUtf8.GetString($bytes)
        }
    }
    catch {
        return [pscustomobject]@{
            IsText = $true
            Content = [System.Text.Encoding]::GetEncoding(1252).GetString($bytes)
        }
    }
}

function Assert-NoPersonalArchiveContent(
    [string]$Path,
    [string]$Location,
    [object[]]$BytePatterns
) {
    $binaryBytes = [System.IO.File]::ReadAllBytes($Path)
    Assert-NoPersonalBytes $binaryBytes $BytePatterns $Location

    if (-not (Test-ZipSignature $binaryBytes)) {
        return
    }

    $archive = $null
    try {
        $archive = [System.IO.Compression.ZipFile]::OpenRead($Path)
        foreach ($entry in $archive.Entries) {
            if ([string]::IsNullOrEmpty($entry.Name)) {
                continue
            }

            $entryStream = $null
            $entryMemory = $null
            try {
                $entryStream = $entry.Open()
                $entryMemory = New-Object System.IO.MemoryStream
                $entryStream.CopyTo($entryMemory)
                Assert-NoPersonalBytes `
                    $entryMemory.ToArray() `
                    $BytePatterns `
                    "$Location, entrada $($entry.FullName)"
            }
            finally {
                if ($null -ne $entryMemory) {
                    $entryMemory.Dispose()
                }
                if ($null -ne $entryStream) {
                    $entryStream.Dispose()
                }
            }
        }
    }
    catch {
        if ($_.Exception.Message.StartsWith('Dados pessoais encontrados em ')) {
            throw
        }
        throw "Falha ao inspecionar arquivo ZIP/OPC em $Location. $($_.Exception.Message)"
    }
    finally {
        if ($null -ne $archive) {
            $archive.Dispose()
        }
    }
}

$personalPathPattern = 'C:' + '\' + 'Users' + '\'
$personalNamePattern = 'leo' + 'na'
$personalPatterns = @($personalPathPattern, $personalNamePattern)

$personalBytePatterns = @(
    foreach ($personalPattern in $personalPatterns) {
        [pscustomobject]@{
            Encoding = 'ASCII/UTF-8'
            Bytes = [System.Text.Encoding]::UTF8.GetBytes($personalPattern)
        }
        [pscustomobject]@{
            Encoding = 'UTF-16LE'
            Bytes = [System.Text.Encoding]::Unicode.GetBytes($personalPattern)
        }
    }
)

$requiredFiles = @(
    'README.md',
    'docs/modelo-power-bi.md',
    'assets/dashboard-overview.png',
    'case-bi-construtora-pride.pdf',
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
    'dados sinteticos',
    'Estado atual do modelo',
    'Limitacoes conhecidas'
)

foreach ($requiredText in $requiredReadmeTexts) {
    Assert-True ($readmeContent.Contains($requiredText)) "README.md nao contem o texto obrigatorio: $requiredText"
}

$semanticModelDefinition = Join-Path $root 'case-bi-construtora-pride.SemanticModel\definition'
$modelPath = Join-Path $semanticModelDefinition 'model.tmdl'
$relationshipsPath = Join-Path $semanticModelDefinition 'relationships.tmdl'

foreach ($tmdlPath in @($modelPath, $relationshipsPath)) {
    Assert-True (Test-Path -LiteralPath $tmdlPath -PathType Leaf) "Arquivo TMDL obrigatorio ausente: $tmdlPath"
}

$modelContent = Get-Content -LiteralPath $modelPath -Raw -Encoding UTF8
$relationshipsContent = Get-Content -LiteralPath $relationshipsPath -Raw -Encoding UTF8

Assert-True ($modelContent -match '__PBI_TimeIntelligenceEnabled\s*=\s*1') 'O teste deve refletir a data/hora automatica ativa no modelo atual.'
foreach ($tableName in @(
    'dClientes',
    'fVendas',
    'DateTableTemplate_f07a36fe-a879-4bb0-9f89-0436de75f486',
    'LocalDateTable_c0dc44ec-6ecb-422a-8114-a4c92dfc53ca',
    'dMetas',
    'dCalendario',
    'Medidas'
)) {
    Assert-True ($modelContent -match "(?m)^ref table $([regex]::Escape($tableName))\s*$") "Tabela atual nao referenciada em model.tmdl: $tableName"
}

$relationshipCount = ([regex]::Matches($relationshipsContent, '(?m)^relationship\b')).Count
Assert-True ($relationshipCount -eq 4) "relationships.tmdl deve conter os 4 relacionamentos atuais; encontrado: $relationshipCount"
$bidirectionalCount = ([regex]::Matches($relationshipsContent, '(?m)^\s*crossFilteringBehavior:\s*bothDirections\s*$')).Count
Assert-True ($bidirectionalCount -eq 3) "O estado atual deve conter 3 relacionamentos bidirecionais; encontrado: $bidirectionalCount"

$sourceTables = @('fVendas', 'dClientes', 'dMetas')
foreach ($tableName in $sourceTables) {
    $tablePath = Join-Path $semanticModelDefinition "tables\$tableName.tmdl"
    Assert-True (Test-Path -LiteralPath $tablePath -PathType Leaf) "Tabela TMDL obrigatoria ausente: $tableName"
    $tableContent = Get-Content -LiteralPath $tablePath -Raw -Encoding UTF8
    Assert-True ($tableContent -match 'File\.Contents\(') "$tableName.tmdl deve manter a fonte local documentada."
}

$trackedFiles = @(& git -C $root ls-files)
Assert-True ($LASTEXITCODE -eq 0) 'git ls-files falhou.'

$forbiddenTrackedFiles = @(
    $trackedFiles | Where-Object {
        $_ -match '(^|/)\.pbi/' -or
        $_ -match '(^|/)\.claude/settings\.local\.json$' -or
        $_ -eq 'Desafio_Analista_Indicadores.docx'
    }
)

Assert-True ($forbiddenTrackedFiles.Count -eq 0) (
    "Arquivos locais nao podem estar rastreados:`n" +
    ($forbiddenTrackedFiles -join "`n")
)

$untrackedFiles = @(& git -C $root ls-files --others --exclude-standard)
Assert-True ($LASTEXITCODE -eq 0) 'git ls-files para untracked falhou.'

$relevantWorkingTreePaths = @{}
foreach ($relevantPath in @($trackedFiles) + @($untrackedFiles)) {
    $relevantWorkingTreePaths[$relevantPath.Replace('\', '/')] = $true
}

$previousErrorActionPreference = $ErrorActionPreference
try {
    $ErrorActionPreference = 'Continue'
    $cachedPersonalMatches = @(
        & git -C $root grep --cached -n -i -F `
            -e $personalPathPattern `
            -e $personalNamePattern `
            -- . `
            ':(exclude)docs/superpowers/**' `
            ':(exclude)case-bi-construtora-pride.SemanticModel/definition/tables/fVendas.tmdl' `
            ':(exclude)case-bi-construtora-pride.SemanticModel/definition/tables/dClientes.tmdl' `
            ':(exclude)case-bi-construtora-pride.SemanticModel/definition/tables/dMetas.tmdl' 2>&1
    )
    $cachedGrepExitCode = $LASTEXITCODE
}
finally {
    $ErrorActionPreference = $previousErrorActionPreference
}

if ($cachedGrepExitCode -eq 0) {
    Assert-True $false (
        "Dados pessoais encontrados no indice Git:`n" +
        ($cachedPersonalMatches -join "`n")
    )
}

Assert-True ($cachedGrepExitCode -eq 1) "git grep --cached falhou com exit code $cachedGrepExitCode."

$binaryExtensions = @('.pbix', '.xlsx', '.docx', '.pdf')
$personalTextMatches = @(
    foreach ($textFile in Get-ChildItem -LiteralPath $root -Recurse -File) {
        $relativeTextPath = $textFile.FullName.Substring($root.Length).TrimStart([char[]]'\/').Replace('\', '/')
        if (
            -not $relevantWorkingTreePaths.ContainsKey($relativeTextPath) -or
            (Test-ExcludedTextPath $relativeTextPath) -or
            $textFile.Extension.ToLowerInvariant() -in $binaryExtensions
        ) {
            continue
        }

        $textFileContent = Get-TextFileContent $textFile.FullName
        if (-not $textFileContent.IsText) {
            continue
        }

        $lineNumber = 0
        foreach ($line in [regex]::Split($textFileContent.Content, '\r?\n')) {
            $lineNumber++
            foreach ($personalPattern in $personalPatterns) {
                if ($line.IndexOf($personalPattern, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
                    "${relativeTextPath}:${lineNumber}:$line"
                    break
                }
            }
        }
    }
)

Assert-True ($personalTextMatches.Count -eq 0) (
    "Dados pessoais encontrados em arquivos de texto do working tree:`n" +
    ($personalTextMatches -join "`n")
)

Add-Type -AssemblyName System.IO.Compression.FileSystem

$trackedBinaryPaths = @(
    $trackedFiles | Where-Object {
        [System.IO.Path]::GetExtension($_).ToLowerInvariant() -in $binaryExtensions -and
        $_ -ne 'case-bi-construtora-pride.pbix'
    }
)

foreach ($trackedBinaryPath in $trackedBinaryPaths) {
    $blobId = (& git -C $root rev-parse ":$trackedBinaryPath").Trim()
    Assert-True ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrWhiteSpace($blobId)) (
        "Nao foi possivel localizar o blob no indice Git: $trackedBinaryPath"
    )

    $temporaryBlobPath = [System.IO.Path]::GetTempFileName()
    try {
        Push-Location $root
        try {
            $gitProcess = Start-Process `
                -FilePath 'git' `
                -ArgumentList @('cat-file', 'blob', $blobId) `
                -RedirectStandardOutput $temporaryBlobPath `
                -NoNewWindow `
                -Wait `
                -PassThru
        }
        finally {
            Pop-Location
        }

        Assert-True ($gitProcess.ExitCode -eq 0) (
            "git cat-file falhou para o arquivo no indice: $trackedBinaryPath"
        )
        Assert-NoPersonalArchiveContent `
            $temporaryBlobPath `
            "indice Git $trackedBinaryPath" `
            $personalBytePatterns
    }
    finally {
        Remove-Item -LiteralPath $temporaryBlobPath -Force -ErrorAction SilentlyContinue
    }
}

$binaryFiles = @(
    Get-ChildItem -LiteralPath $root -Recurse -File | Where-Object {
        if ($_.Extension.ToLowerInvariant() -notin $binaryExtensions) {
            return $false
        }

        $relativePath = $_.FullName.Substring($root.Length).TrimStart([char[]]'\/').Replace('\', '/')
        return (
            $relativePath -notmatch '(^|/)\.git(/|$)' -and
            $relativePath -notmatch '^docs/superpowers(/|$)' -and
            $relativePath -notmatch '(^|/)\.pbi(/|$)' -and
            $relativePath -ne 'case-bi-construtora-pride.pbix'
        )
    }
)

foreach ($binaryFile in $binaryFiles) {
    $relativeBinaryPath = $binaryFile.FullName.Substring($root.Length).TrimStart([char[]]'\/').Replace('\', '/')
    Assert-NoPersonalArchiveContent `
        $binaryFile.FullName `
        "binario $relativeBinaryPath" `
        $personalBytePatterns
}

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

$visualRoot = Join-Path $reportRoot 'definition\pages\516f47fa1bac5767e01c\visuals'
$visualFiles = @(Get-ChildItem -LiteralPath $visualRoot -Recurse -File -Filter 'visual.json')
Assert-True ($visualFiles.Count -eq 9) "O relatorio deve conter os 9 visuais atuais; encontrado: $($visualFiles.Count)"

$expectedVisuals = @{
    '1f8e4700b7d9101d683a' = 'donutChart'
    '26a2d7a119062d88b108' = 'htmlContent443BE3AD55E043BF878BED274D3A6855'
    '3b65c806b57a59dae6e7' = 'SmartFilterBySQLBI1458262140625'
    '3bf3d02da0a5c6c25019' = 'lineStackedColumnComboChart'
    '8ea21b49662a4d58a8d1' = 'htmlContent443BE3AD55E043BF878BED274D3A6855'
    'a50db6ca0c6445255352' = 'htmlContent443BE3AD55E043BF878BED274D3A6855'
    'ae39f2b835ab32a1d092' = 'columnChart'
    'c9e1f4a2b3d5067891ab' = 'htmlContent443BE3AD55E043BF878BED274D3A6855'
    'd94cdba159ca98baede8' = 'SmartFilterBySQLBI1458262140625'
}

foreach ($visualId in $expectedVisuals.Keys) {
    $visualPath = Join-Path $visualRoot "$visualId\visual.json"
    Assert-True (Test-Path -LiteralPath $visualPath -PathType Leaf) "Visual atual ausente: $visualId"
    $visualDefinition = Get-Content -LiteralPath $visualPath -Raw -Encoding UTF8 | ConvertFrom-Json
    Assert-True ($visualDefinition.visual.visualType -eq $expectedVisuals[$visualId]) (
        "Tipo inesperado para o visual $visualId`: $($visualDefinition.visual.visualType)"
    )
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
Assert-True ($measureNames.Count -eq 39) "O modelo atual deve conter 39 medidas; encontrado: $($measureNames.Count)"

$modelDocumentationContent = Get-Content -LiteralPath $modelDocumentationPath -Raw -Encoding UTF8
foreach ($measureName in $measureNames) {
    $measureHeadingPattern = '(?m)^###[ \t]+' + [regex]::Escape($measureName) + '[ \t]*\r?$'
    Assert-True ([regex]::IsMatch($modelDocumentationContent, $measureHeadingPattern)) "Heading de medida ausente em docs/modelo-power-bi.md: $measureName"
}

Write-Host 'Validacao publica concluida com sucesso.'
