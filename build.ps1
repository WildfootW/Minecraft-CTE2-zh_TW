# Build the resource pack zip from resourcepack/ with forward-slash entry names.
# Usage: powershell -ExecutionPolicy Bypass -File build.ps1
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$pack = Join-Path $root 'resourcepack'
$dist = Join-Path $root 'dist'
$zipPath = Join-Path $dist 'CTE2-v1.1.3-zh_tw-WildfootW.zip'

if (-not (Test-Path $pack)) { throw "resourcepack folder not found: $pack" }
New-Item -ItemType Directory -Force $dist | Out-Null
if (Test-Path $zipPath) { [System.IO.File]::Delete($zipPath) }

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

# NOTE: [System.IO.Compression.ZipFile]::CreateFromDirectory on .NET Framework
# writes entry names with backslashes, which Minecraft cannot read.
# Build entries manually with forward slashes instead.
$fs = [System.IO.File]::Create($zipPath)
$zip = New-Object System.IO.Compression.ZipArchive($fs, [System.IO.Compression.ZipArchiveMode]::Create)
Get-ChildItem $pack -Recurse -File | ForEach-Object {
    $rel = $_.FullName.Substring($pack.Length + 1)
    $rel = $rel -replace '\\', '/'
    $entry = $zip.CreateEntry($rel, [System.IO.Compression.CompressionLevel]::Optimal)
    $es = $entry.Open()
    $bytes = [System.IO.File]::ReadAllBytes($_.FullName)
    $es.Write($bytes, 0, $bytes.Length)
    $es.Dispose()
}
$zip.Dispose()
$fs.Dispose()

$size = [math]::Round((Get-Item $zipPath).Length / 1KB, 1)
Write-Output "Built: $zipPath ($size KB)"
