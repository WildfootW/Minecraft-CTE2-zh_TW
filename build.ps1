# Build the all-in-one resource pack zip.
# Layers: community/ (bundled community translation packs, lower priority)
#         resourcepack/ (this project's translations, overrides community on conflicts)
# Usage: powershell -ExecutionPolicy Bypass -File build.ps1
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$community = Join-Path $root 'community'
$pack = Join-Path $root 'resourcepack'
$dist = Join-Path $root 'dist'
$zipPath = Join-Path $dist 'CTE2-v1.1.3-zh_tw-WildfootW.zip'

if (-not (Test-Path $pack)) { throw "resourcepack folder not found: $pack" }
New-Item -ItemType Directory -Force $dist | Out-Null
if (Test-Path $zipPath) { [System.IO.File]::Delete($zipPath) }

# collect files: community first, then resourcepack overrides same relative path
$files = @{}
if (Test-Path $community) {
    Get-ChildItem $community -Recurse -File | ForEach-Object {
        $rel = $_.FullName.Substring($community.Length + 1)
        $files[$rel] = $_.FullName
    }
}
Get-ChildItem $pack -Recurse -File | ForEach-Object {
    $rel = $_.FullName.Substring($pack.Length + 1)
    $files[$rel] = $_.FullName
}

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

# NOTE: [System.IO.Compression.ZipFile]::CreateFromDirectory on .NET Framework
# writes entry names with backslashes, which Minecraft cannot read.
# Build entries manually with forward slashes instead.
$fs = [System.IO.File]::Create($zipPath)
$zip = New-Object System.IO.Compression.ZipArchive($fs, [System.IO.Compression.ZipArchiveMode]::Create)
foreach ($rel in ($files.Keys | Sort-Object)) {
    $entryName = $rel -replace '\\', '/'
    $entry = $zip.CreateEntry($entryName, [System.IO.Compression.CompressionLevel]::Optimal)
    $es = $entry.Open()
    $bytes = [System.IO.File]::ReadAllBytes($files[$rel])
    $es.Write($bytes, 0, $bytes.Length)
    $es.Dispose()
}
$zip.Dispose()
$fs.Dispose()

$size = [math]::Round((Get-Item $zipPath).Length / 1MB, 2)
Write-Output "Built: $zipPath ($($files.Count) entries, $size MB)"
