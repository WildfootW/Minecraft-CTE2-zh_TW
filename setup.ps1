# CTE2 v1.1.3 繁體中文化 安裝程式
# 互動模式:      powershell -ExecutionPolicy Bypass -File setup.ps1
# 建置資源包:    powershell -ExecutionPolicy Bypass -File setup.ps1 -Build
# 建置完整安裝包: powershell -ExecutionPolicy Bypass -File setup.ps1 -BuildFull
param([switch]$Build, [switch]$BuildFull)

$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
if (-not $root) { $root = (Get-Location).Path }
$PackFile = 'CTE2-v1.1.3-zh_tw-WildfootW.zip'
$FullFile = 'CTE2-v1.1.3-zh_tw-full.zip'
$BackupDirName = 'quests_backup_original'
$ReleaseZipUrl = "https://github.com/WildfootW/Minecraft-CTE2-zh_TW/releases/latest/download/$PackFile"
$FullZipUrl = "https://github.com/WildfootW/Minecraft-CTE2-zh_TW/releases/latest/download/$FullFile"

# PS 5.1 預設 TLS 太舊,連 GitHub 需要 TLS 1.2
try { [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12 } catch { }

# ---------- 建置 ----------
function Write-Zip([hashtable]$files, [string]$zipPath) {
    # 注意:.NET Framework 的 CreateFromDirectory 會用反斜線當 zip 路徑分隔,
    # Minecraft 讀不到,必須手動用正斜線建立條目。
    Add-Type -AssemblyName System.IO.Compression
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    if (Test-Path $zipPath) { [System.IO.File]::Delete($zipPath) }
    $fs = [System.IO.File]::Create($zipPath)
    $zip = New-Object System.IO.Compression.ZipArchive($fs, [System.IO.Compression.ZipArchiveMode]::Create)
    foreach ($rel in ($files.Keys | Sort-Object)) {
        $entryName = $rel.Replace('\', '/')
        $entry = $zip.CreateEntry($entryName, [System.IO.Compression.CompressionLevel]::Optimal)
        $es = $entry.Open()
        $bytes = [System.IO.File]::ReadAllBytes($files[$rel])
        $es.Write($bytes, 0, $bytes.Length)
        $es.Dispose()
    }
    $zip.Dispose()
    $fs.Dispose()
    $size = [math]::Round((Get-Item $zipPath).Length / 1MB, 2)
    Write-Host "已建置: $zipPath ($($files.Count) 個條目, $size MB)" -ForegroundColor Green
}

function Get-TreeFiles([string]$base, [string]$prefix) {
    $map = @{}
    Get-ChildItem $base -Recurse -File | ForEach-Object {
        $rel = $_.FullName.Substring($base.Length + 1)
        if ($prefix) { $rel = Join-Path $prefix $rel }
        $map[$rel] = $_.FullName
    }
    return $map
}

function Build-Pack {
    $pack = Join-Path $root 'resourcepack'
    if (-not (Test-Path $pack)) { throw "找不到 resourcepack 資料夾: $pack" }
    $dist = Join-Path $root 'dist'
    New-Item -ItemType Directory -Force $dist | Out-Null
    $zipPath = Join-Path $dist $PackFile

    # 疊層:community 墊底,resourcepack 覆蓋同路徑檔案
    $files = @{}
    $community = Join-Path $root 'community'
    if (Test-Path $community) { $files += Get-TreeFiles $community '' }
    foreach ($kv in (Get-TreeFiles $pack '').GetEnumerator()) { $files[$kv.Key] = $kv.Value }

    Write-Zip $files $zipPath
    return $zipPath
}

function Build-Full {
    $packZip = Build-Pack
    $dist = Join-Path $root 'dist'
    $files = @{}
    $files[$PackFile] = $packZip
    $files['setup.ps1'] = Join-Path $root 'setup.ps1'
    $files += Get-TreeFiles (Join-Path $root 'ftbquests') 'ftbquests'
    $extras = Join-Path $root 'extras'
    if (Test-Path $extras) { $files += Get-TreeFiles $extras 'extras' }
    $zipPath = Join-Path $dist $FullFile
    Write-Zip $files $zipPath
    return $zipPath
}

if ($BuildFull) { Build-Full | Out-Null; exit 0 }
if ($Build) { Build-Pack | Out-Null; exit 0 }

# ---------- 取得檔案(本地優先,否則從 GitHub 下載) ----------
function Get-PackZip {
    $built = Join-Path $root "dist\$PackFile"
    if (Test-Path $built) { return $built }
    $beside = Join-Path $root $PackFile
    if (Test-Path $beside) { return $beside }
    if (Test-Path (Join-Path $root 'resourcepack')) {
        Write-Host '尚未建置資源包,開始建置…'
        return (Build-Pack)
    }
    Write-Host '本地沒有資源包,從 GitHub Release 下載…' -ForegroundColor Cyan
    New-Item -ItemType Directory -Force (Join-Path $root 'dist') | Out-Null
    Invoke-WebRequest -Uri $ReleaseZipUrl -OutFile $built -UseBasicParsing
    Write-Host "✔ 已下載 $PackFile" -ForegroundColor Green
    return $built
}

function Confirm-QuestFiles {
    if (Test-Path (Join-Path $root 'ftbquests\chapters')) { return $true }
    Write-Host '本地沒有任務書翻譯檔,從 GitHub Release 下載完整安裝包…' -ForegroundColor Cyan
    $tmpZip = Join-Path $env:TEMP 'cte2_zhtw_full.zip'
    Invoke-WebRequest -Uri $FullZipUrl -OutFile $tmpZip -UseBasicParsing
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [System.IO.Compression.ZipFile]::OpenRead($tmpZip)
    try {
        foreach ($e in $zip.Entries) {
            $name = $e.FullName.Replace('\', '/')
            if ($name -match '^(ftbquests|extras)/(.+)$' -and -not $name.EndsWith('/')) {
                $dst = Join-Path $root ($name.Replace('/', '\'))
                New-Item -ItemType Directory -Force (Split-Path $dst) | Out-Null
                [System.IO.Compression.ZipFileExtensions]::ExtractToFile($e, $dst, $true)
            }
        }
    } finally { $zip.Dispose(); Remove-Item $tmpZip -Force -ErrorAction SilentlyContinue }
    Write-Host '✔ 已取得任務書翻譯與選配檔案' -ForegroundColor Green
    return (Test-Path (Join-Path $root 'ftbquests\chapters'))
}

# ---------- 工具 ----------
function Test-GameRunning {
    $p = Get-Process -Name javaw, java -ErrorAction SilentlyContinue | Select-Object -First 1
    return [bool]$p
}

function Test-CTE2Instance([string]$path) {
    if (-not (Test-Path (Join-Path $path 'config\ftbquests'))) { return $false }
    if (-not (Test-Path (Join-Path $path 'config\openloader'))) { return $false }
    return $true
}

function Find-CTE2Instances {
    $found = @()
    $roots = @(
        (Join-Path $env:USERPROFILE 'curseforge\minecraft\Instances'),
        (Join-Path $env:USERPROFILE 'Documents\curseforge\minecraft\Instances'),
        (Join-Path $env:APPDATA '.minecraft')
    )
    foreach ($r in $roots) {
        if (-not (Test-Path $r)) { continue }
        if (Test-CTE2Instance $r) { $found += $r; continue }
        Get-ChildItem $r -Directory -ErrorAction SilentlyContinue | ForEach-Object {
            if (Test-CTE2Instance $_.FullName) { $found += $_.FullName }
        }
    }
    return $found
}

function Select-Instance {
    $instances = @(Find-CTE2Instances)
    Write-Host ''
    if ($instances.Count -gt 0) {
        Write-Host '偵測到以下 CTE2 實例:' -ForegroundColor Cyan
        for ($i = 0; $i -lt $instances.Count; $i++) {
            Write-Host "  [$($i+1)] $($instances[$i])"
        }
        Write-Host '  [0] 手動輸入路徑'
        $sel = Read-Host '請選擇'
        if ($sel -match '^\d+$' -and [int]$sel -ge 1 -and [int]$sel -le $instances.Count) {
            return $instances[[int]$sel - 1]
        }
    } else {
        Write-Host '沒有在常見位置偵測到 CTE2 實例。' -ForegroundColor Yellow
    }
    while ($true) {
        $p = Read-Host '請輸入實例資料夾完整路徑(留空取消)'
        if ([string]::IsNullOrWhiteSpace($p)) { return $null }
        $p = $p.Trim('"')
        if (Test-CTE2Instance $p) { return $p }
        Write-Host '該路徑不像 CTE2 實例(需含 config\ftbquests 與 config\openloader),請重試。' -ForegroundColor Yellow
    }
}

# ---------- 安裝 ----------
function Install-Translation([string]$inst) {
    if (Test-GameRunning) {
        Write-Host '偵測到 Minecraft 正在執行,請先關閉遊戲再安裝!' -ForegroundColor Red
        return
    }

    # 1) 資源包
    $zipPath = Get-PackZip
    $resDir = Join-Path $inst 'config\openloader\resources'
    New-Item -ItemType Directory -Force $resDir | Out-Null
    Copy-Item $zipPath $resDir -Force
    Write-Host "✔ 資源包已放入 $resDir" -ForegroundColor Green

    # 2) 任務書(先備份原檔,只備份一次)
    if (-not (Confirm-QuestFiles)) {
        Write-Host '⚠ 無法取得任務書翻譯檔,略過任務書安裝' -ForegroundColor Yellow
    }
    $questDir = Join-Path $inst 'config\ftbquests\quests'
    $backupDir = Join-Path $inst "config\ftbquests\$BackupDirName"
    if ((Test-Path $questDir) -and (Test-Path (Join-Path $root 'ftbquests\chapters'))) {
        if (-not (Test-Path $backupDir)) {
            Copy-Item $questDir $backupDir -Recurse
            Write-Host "✔ 原版任務書已備份到 $backupDir" -ForegroundColor Green
        }
        Copy-Item (Join-Path $root 'ftbquests\chapters\*.snbt') (Join-Path $questDir 'chapters') -Force
        Copy-Item (Join-Path $root 'ftbquests\reward_tables\*.snbt') (Join-Path $questDir 'reward_tables') -Force
        Copy-Item (Join-Path $root 'ftbquests\chapter_groups.snbt') $questDir -Force
        Write-Host '✔ 任務書翻譯已安裝' -ForegroundColor Green
    } else {
        Write-Host '⚠ 找不到 config\ftbquests\quests,略過任務書(請先啟動過一次遊戲)' -ForegroundColor Yellow
    }

    # 3) options.txt:語言 + 啟用資源包
    $opt = Join-Path $inst 'options.txt'
    if (Test-Path $opt) {
        $lines = [System.IO.File]::ReadAllLines($opt)
        $entry = '"resources/' + $PackFile + '"'
        for ($i = 0; $i -lt $lines.Count; $i++) {
            if ($lines[$i].StartsWith('lang:')) { $lines[$i] = 'lang:zh_tw' }
            if ($lines[$i].StartsWith('resourcePacks:') -and ($lines[$i].IndexOf($PackFile) -lt 0)) {
                $lines[$i] = $lines[$i] -replace '\]$', (',' + $entry + ']')
            }
        }
        [System.IO.File]::WriteAllLines($opt, $lines, (New-Object System.Text.UTF8Encoding($false)))
        Write-Host '✔ 語言已設為 zh_tw、資源包已啟用(最高優先)' -ForegroundColor Green
    } else {
        Write-Host '⚠ 找不到 options.txt,請啟動遊戲後手動設定語言並啟用資源包' -ForegroundColor Yellow
    }

    # 4) MineMenu 輪盤(選配)
    $mmSrc = Join-Path $root 'extras\minemenu\menu.json'
    $mmDir = Join-Path $inst 'minemenu'
    if ((Test-Path $mmSrc) -and (Test-Path $mmDir)) {
        $ans = Read-Host '要一併中文化 H 鍵輪盤選單嗎?(y/N)'
        if ($ans -match '^[Yy]') {
            $mmDst = Join-Path $mmDir 'menu.json'
            if ((Test-Path $mmDst) -and (-not (Test-Path "$mmDst.bak"))) { Copy-Item $mmDst "$mmDst.bak" }
            Copy-Item $mmSrc $mmDst -Force
            Write-Host '✔ 輪盤選單已中文化(原檔備份為 menu.json.bak)' -ForegroundColor Green
        }
    }

    Write-Host ''
    Write-Host '安裝完成!啟動遊戲即可。' -ForegroundColor Cyan
}

# ---------- 解除安裝 ----------
function Uninstall-Translation([string]$inst) {
    if (Test-GameRunning) {
        Write-Host '偵測到 Minecraft 正在執行,請先關閉遊戲再解除安裝!' -ForegroundColor Red
        return
    }

    # 1) 移除資源包
    $zipDst = Join-Path $inst "config\openloader\resources\$PackFile"
    if (Test-Path $zipDst) { Remove-Item $zipDst -Force; Write-Host '✔ 資源包已移除' -ForegroundColor Green }

    # 2) 還原任務書
    $questDir = Join-Path $inst 'config\ftbquests\quests'
    $backupDir = Join-Path $inst "config\ftbquests\$BackupDirName"
    if (Test-Path $backupDir) {
        Copy-Item (Join-Path $backupDir '*') $questDir -Recurse -Force
        Write-Host '✔ 任務書已還原為原版(備份保留)' -ForegroundColor Green
    } else {
        Write-Host '⚠ 找不到任務書備份,略過還原' -ForegroundColor Yellow
    }

    # 3) options.txt 移除資源包條目
    $opt = Join-Path $inst 'options.txt'
    if (Test-Path $opt) {
        $lines = [System.IO.File]::ReadAllLines($opt)
        for ($i = 0; $i -lt $lines.Count; $i++) {
            if ($lines[$i].StartsWith('resourcePacks:')) {
                $lines[$i] = $lines[$i].Replace(',"resources/' + $PackFile + '"', '')
            }
        }
        [System.IO.File]::WriteAllLines($opt, $lines, (New-Object System.Text.UTF8Encoding($false)))
        Write-Host '✔ options.txt 已清理(語言設定保留)' -ForegroundColor Green
    }

    # 4) 還原 MineMenu
    $mmBak = Join-Path $inst 'minemenu\menu.json.bak'
    if (Test-Path $mmBak) {
        Copy-Item $mmBak (Join-Path $inst 'minemenu\menu.json') -Force
        Write-Host '✔ 輪盤選單已還原' -ForegroundColor Green
    }

    Write-Host ''
    Write-Host '解除安裝完成。' -ForegroundColor Cyan
}

# ---------- 主選單 ----------
Write-Host '=============================================='
Write-Host ' Craft to Exile 2 v1.1.3 繁體中文化 安裝程式'
Write-Host '=============================================='

$instance = Select-Instance
if (-not $instance) { Write-Host '未選擇實例,結束。'; exit 0 }

while ($true) {
    Write-Host ''
    Write-Host "目前實例: $instance" -ForegroundColor Cyan
    Write-Host '  [1] 安裝 / 更新翻譯'
    Write-Host '  [2] 解除安裝翻譯'
    Write-Host '  [3] 重新建置資源包 zip'
    Write-Host '  [4] 更換實例'
    Write-Host '  [0] 離開'
    $choice = Read-Host '請選擇'
    switch ($choice) {
        '1' { Install-Translation $instance }
        '2' { Uninstall-Translation $instance }
        '3' { Build-Pack | Out-Null }
        '4' { $sel = Select-Instance; if ($sel) { $instance = $sel } }
        '0' { exit 0 }
        default { Write-Host '無效選項' -ForegroundColor Yellow }
    }
}
