param(
    [string]$Image = "citygml-tools:min",
    [switch]$SkipBuild,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$CliArgs
)

$ErrorActionPreference = "Stop"

$testDataPath = Join-Path $PSScriptRoot "test_data"
if (-not (Test-Path $testDataPath)) {
    throw "Directory 'test_data' not found: $testDataPath"
}

if (-not $SkipBuild) {
    docker build -t $Image .
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}

if (-not $CliArgs -or $CliArgs.Count -eq 0) {
    $CliArgs = @("stats", "--no-json-report", "/data")
}

docker run --rm -v "${testDataPath}:/data:ro" $Image @CliArgs
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}
