<#
  SUN TECH UNLIMITED - GAME GRID
  PowerShell fallback server.

  This exists so the drive still works on a locked-down Windows machine that
  has no Node and no way to install it. Every Windows PC since Windows 7 has
  PowerShell and .NET's HttpListener, and binding to http://localhost:PORT/
  does not need administrator rights.

  It serves the same URLs as system/server.js. It is slower and it does not
  handle many players at once, but there is only ever one player.
#>

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$SystemDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir   = Split-Path -Parent $SystemDir
$UiDir     = Join-Path $SystemDir 'ui'
$GamesDir  = Join-Path $RootDir  'games'
$Manifest  = Join-Path $GamesDir 'games.json'

if (-not (Test-Path $GamesDir)) { New-Item -ItemType Directory -Path $GamesDir | Out-Null }

$Mime = @{
  '.html'='text/html; charset=utf-8'; '.htm'='text/html; charset=utf-8'
  '.js'='text/javascript; charset=utf-8'; '.mjs'='text/javascript; charset=utf-8'
  '.css'='text/css; charset=utf-8'; '.json'='application/json; charset=utf-8'
  '.png'='image/png'; '.jpg'='image/jpeg'; '.jpeg'='image/jpeg'; '.gif'='image/gif'
  '.svg'='image/svg+xml'; '.webp'='image/webp'; '.ico'='image/x-icon'
  '.woff2'='font/woff2'; '.woff'='font/woff'; '.ttf'='font/ttf'; '.otf'='font/otf'
  '.mp3'='audio/mpeg'; '.ogg'='audio/ogg'; '.wav'='audio/wav'
  '.mp4'='video/mp4'; '.webm'='video/webm'; '.txt'='text/plain; charset=utf-8'
}

# "grid-runner/index.html" -> "Grid Runner", not "Index": when the file is the
# folder's index, the folder name is what the student actually named the game.
function Get-Pretty([string]$relPath) {
  $parts = @($relPath -split '[\\/]' | Where-Object { $_ })
  $name  = if ($parts.Count) { $parts[-1] } else { '' }
  $bare  = [System.IO.Path]::GetFileNameWithoutExtension($name)
  if ($bare -match '^index$' -and $parts.Count -gt 1) { $name = $parts[-2] }
  $base = [System.IO.Path]::GetFileNameWithoutExtension($name)
  $base = ($base -replace '[-_]+', ' ').Trim()
  (Get-Culture).TextInfo.ToTitleCase($base)
}

function Get-Slug([string]$s) {
  $t = ($s.ToLower() -replace '[^a-z0-9]+', '-').Trim('-')
  if ([string]::IsNullOrWhiteSpace($t)) { 'game' } else { $t }
}

# Refuse anything that would climb out of the folder we mean to serve.
function Resolve-Safe([string]$base, [string]$rel) {
  $rel = $rel -replace '^[\\/]+', ''
  $full = [System.IO.Path]::GetFullPath((Join-Path $base $rel))
  $root = [System.IO.Path]::GetFullPath($base)
  if ($full -eq $root -or $full.StartsWith($root + [System.IO.Path]::DirectorySeparatorChar)) { $full } else { $null }
}

function Get-HtmlFiles {
  if (-not (Test-Path $GamesDir)) { return @() }
  Get-ChildItem -Path $GamesDir -Recurse -File -Include *.html, *.htm -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch '[\\/][_.]' } |
    ForEach-Object { $_.FullName.Substring($GamesDir.Length + 1).Replace('\', '/') }
}

function Read-Manifest {
  $problems = New-Object System.Collections.ArrayList
  $list     = New-Object System.Collections.ArrayList
  $doc = $null

  if (Test-Path $Manifest) {
    try { $doc = Get-Content $Manifest -Raw -Encoding UTF8 | ConvertFrom-Json }
    catch {
      [void]$problems.Add(@{ level='error'; where='games.json'
        message = "This file is not valid JSON, so no titles or covers are being used. " + $_.Exception.Message })
    }
  } else {
    [void]$problems.Add(@{ level='info'; where='games.json'
      message='No manifest yet - every HTML file in the games folder is being listed automatically.' })
  }

  if ($doc) {
    $entries = if ($doc -is [array]) { $doc } elseif ($doc.games) { $doc.games } else { $null }
    if ($null -eq $entries) {
      [void]$problems.Add(@{ level='error'; where='games.json'; message='Expected a "games" array at the top level.' })
    } else {
      foreach ($g in $entries) {
        $rel = if ($g.path) { $g.path } elseif ($g.file) { $g.file } else { $g.entry }
        $label = if ($g.title) { $g.title } else { 'an entry' }
        if (-not $rel) {
          [void]$problems.Add(@{ level='error'; where=$label; message='Missing "path" - the HTML file to launch, relative to games.json.' })
          continue
        }
        $abs = Resolve-Safe $GamesDir $rel
        $exists = ($abs -and (Test-Path $abs -PathType Leaf))
        if (-not $exists) {
          [void]$problems.Add(@{ level='error'; where=$label; message="Can't find `"$rel`" inside the games folder." })
        }
        $preview = $null
        $pr = if ($g.preview) { $g.preview } elseif ($g.image) { $g.image } else { $g.cover }
        if ($pr) {
          $pabs = Resolve-Safe $GamesDir $pr
          if ($pabs -and (Test-Path $pabs)) { $preview = ($pr -replace '^[\\/]+','').Replace('\','/') }
          else { [void]$problems.Add(@{ level='warn'; where=$label; message="Preview image `"$pr`" was not found - showing the fallback tile instead." }) }
        }
        [void]$list.Add(@{
          id          = if ($g.id) { $g.id } else { Get-Slug ($(if ($g.title) { $g.title } else { $rel })) }
          title       = if ($g.title) { $g.title } else { Get-Pretty $rel }
          author      = [string]$g.author
          description = [string]$g.description
          controls    = [string]$g.controls
          tags        = @($g.tags)
          preview     = $preview
          path        = ($rel -replace '^[\\/]+','').Replace('\','/')
          featured    = [bool]$g.featured
          listed      = $true
          missing     = (-not $exists)
        })
      }
    }
  }

  $claimed = @($list | ForEach-Object { $_.path.ToLower() })
  foreach ($rel in Get-HtmlFiles) {
    if ($claimed -contains $rel.ToLower()) { continue }
    [void]$list.Add(@{
      id=(Get-Slug $rel); title=(Get-Pretty $rel); author=''; description=''
      controls=''; tags=@(); preview=$null; path=$rel; featured=$false; listed=$false; missing=$false
    })
  }

  $sorted = @($list | Sort-Object @{Expression={-[int][bool]$_.featured}}, @{Expression={$_.title}})
  @{ games = $sorted; problems = @($problems) }
}

function Save-ManifestEntry($entry) {
  $doc = [ordered]@{ club='SUN Tech Unlimited'; games=@() }
  if (Test-Path $Manifest) {
    try {
      $parsed = Get-Content $Manifest -Raw -Encoding UTF8 | ConvertFrom-Json
      $existing = if ($parsed -is [array]) { $parsed } elseif ($parsed.games) { $parsed.games } else { @() }
      $doc.games = @($existing | ForEach-Object {
        $h = [ordered]@{}
        $_.PSObject.Properties | ForEach-Object { $h[$_.Name] = $_.Value }
        $h
      })
    } catch {
      $backup = $Manifest -replace '\.json$', ".broken-$(Get-Date -Format yyyyMMddHHmmss).json"
      Copy-Item $Manifest $backup
      throw "games.json could not be parsed, so nothing was changed. A copy was saved as $(Split-Path -Leaf $backup)."
    }
  }
  $games = New-Object System.Collections.ArrayList
  $replaced = $false
  foreach ($g in $doc.games) {
    if ($g.path -eq $entry.path) { [void]$games.Add($entry); $replaced = $true }
    else { [void]$games.Add($g) }
  }
  if (-not $replaced) { [void]$games.Add($entry) }
  $doc.games = @($games)
  ($doc | ConvertTo-Json -Depth 8) | Set-Content -Path $Manifest -Encoding UTF8
}

function Save-Preview([string]$dataUrl, [string]$gamePath) {
  if ($dataUrl -notmatch '^data:image/(png|jpeg|jpg|webp|gif);base64,(.+)$') { return $null }
  $ext = $Matches[1]; if ($ext -eq 'jpeg') { $ext = 'jpg' }
  $bytes = [Convert]::FromBase64String($Matches[2])
  if ($bytes.Length -gt 4MB) { throw 'That image is larger than 4 MB. Try a smaller one.' }
  $dir  = Split-Path -Parent (Join-Path $GamesDir $gamePath)
  $name = (Get-Slug ([System.IO.Path]::GetFileNameWithoutExtension($gamePath))) + "-cover.$ext"
  $target = Join-Path $dir $name
  [System.IO.File]::WriteAllBytes($target, $bytes)
  $target.Substring($GamesDir.Length + 1).Replace('\', '/')
}

# --- start listening ---------------------------------------------------------
$listener = New-Object System.Net.HttpListener
$port = 7331
$bound = $false
for ($i = 0; $i -lt 25 -and -not $bound; $i++) {
  try {
    $listener.Prefixes.Clear()
    $listener.Prefixes.Add("http://localhost:$port/")
    $listener.Start()
    $bound = $true
  } catch { $port++ }
}
if (-not $bound) { Write-Host "`n   Could not open a local port. Close other copies of the Game Grid and try again.`n"; exit 1 }

$target = "http://localhost:$port/"
$state  = Read-Manifest

Write-Host ''
Write-Host '   SUN TECH UNLIMITED  ///  GAME GRID'
Write-Host '   ----------------------------------------------'
Write-Host "   Mode         : PowerShell (no Node on this machine)"
Write-Host "   Games folder : $GamesDir"
Write-Host "   Games found  : $($state.games.Count)"
Write-Host "   Address      : $target"
Write-Host ''

# Chromeless app window if Chrome or Edge is around, otherwise the default browser.
$browsers = @(
  "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
  "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
  "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe",
  "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
  "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe"
)
$exe = $browsers | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1

# The browser profile MUST go on local disk, never on the drive this script is
# running from. A fresh Chrome profile is thousands of tiny files, and USB flash
# has dreadful random-write speed - putting it on the stick leaves the player
# looking at a black window for minutes. Local temp makes the first launch take
# a couple of seconds and every later launch on that machine instant.
$profileBase = Join-Path $env:TEMP 'suntech-game-grid'
try {
  New-Item -ItemType Directory -Force -Path (Join-Path $profileBase 'profile') | Out-Null
  New-Item -ItemType Directory -Force -Path (Join-Path $profileBase 'cache')   | Out-Null
} catch { $profileBase = $null }

if ($exe -and $profileBase) {
  Start-Process $exe -ArgumentList @(
    "--app=$target",
    "--user-data-dir=$(Join-Path $profileBase 'profile')",
    "--disk-cache-dir=$(Join-Path $profileBase 'cache')",
    '--window-size=1280,800', '--no-first-run', '--no-default-browser-check',
    '--autoplay-policy=no-user-gesture-required',
    '--disable-background-networking', '--disable-component-update',
    '--disable-client-side-phishing-detection', '--disable-sync',
    '--disable-default-apps', '--no-service-autorun',
    '--disable-features=Translate,MediaRouter,OptimizationHints,CalculateNativeWinOcclusion'
  ) | Out-Null
  Write-Host '   Opened in a clean app window.'
  Write-Host '   (First run on a computer takes a few seconds while the browser'
  Write-Host '    profile is built locally. Later runs on that machine are instant.)'
} else {
  Start-Process $target | Out-Null
  Write-Host '   Chrome or Edge was not found - opened in your default browser.'
}
Write-Host '   Close this window to shut the Game Grid down.'
Write-Host ''

while ($listener.IsListening) {
  try { $ctx = $listener.GetContext() } catch { break }
  $req = $ctx.Request; $res = $ctx.Response
  $res.Headers.Add('Cache-Control', 'no-store')
  $path = [System.Uri]::UnescapeDataString($req.Url.AbsolutePath)

  try {
    if ($path -eq '/api/games') {
      $json = (Read-Manifest | ConvertTo-Json -Depth 8)
      $b = [Text.Encoding]::UTF8.GetBytes($json)
      $res.ContentType = 'application/json; charset=utf-8'
      $res.OutputStream.Write($b, 0, $b.Length)
    }
    elseif ($path -eq '/api/candidates') {
      $json = (@{ files = @(Get-HtmlFiles) } | ConvertTo-Json -Depth 4)
      $b = [Text.Encoding]::UTF8.GetBytes($json)
      $res.ContentType = 'application/json; charset=utf-8'
      $res.OutputStream.Write($b, 0, $b.Length)
    }
    elseif ($path -eq '/api/add' -and $req.HttpMethod -eq 'POST') {
      $reader = New-Object IO.StreamReader($req.InputStream, [Text.Encoding]::UTF8)
      $body = $reader.ReadToEnd(); $reader.Close()
      $out = @{ ok = $false; error = 'Unknown error.' }
      try {
        $in  = $body | ConvertFrom-Json
        $rel = ($in.path -replace '^[\\/]+','')
        $abs = Resolve-Safe $GamesDir $rel
        if (-not $rel)                    { throw 'Pick the HTML file that starts your game.' }
        if (-not ($abs -and (Test-Path $abs))) { throw "Can't find `"$rel`" inside the games folder." }
        $preview = $null
        if ($in.previewData) { $preview = Save-Preview $in.previewData $rel }
        $entry = [ordered]@{
          id          = Get-Slug ($(if ($in.title) { $in.title } else { $rel }))
          title       = if ($in.title) { [string]$in.title } else { Get-Pretty $rel }
          author      = [string]$in.author
          description = [string]$in.description
          controls    = [string]$in.controls
          tags        = @(($in.tags -split ',') | ForEach-Object { $_.Trim() } | Where-Object { $_ })
          path        = $rel
        }
        if ($preview) { $entry.preview = $preview }
        Save-ManifestEntry $entry
        $out = @{ ok = $true; entry = $entry }
      } catch { $out = @{ ok = $false; error = $_.Exception.Message } }
      $b = [Text.Encoding]::UTF8.GetBytes(($out | ConvertTo-Json -Depth 6))
      $res.ContentType = 'application/json; charset=utf-8'
      $res.OutputStream.Write($b, 0, $b.Length)
    }
    elseif ($path -eq '/api/quit') {
      $b = [Text.Encoding]::UTF8.GetBytes('{"ok":true}')
      $res.ContentType = 'application/json; charset=utf-8'
      $res.OutputStream.Write($b, 0, $b.Length)
      $res.Close(); $listener.Stop(); break
    }
    else {
      $file = $null
      if ($path.StartsWith('/games/')) {
        $file = Resolve-Safe $GamesDir $path.Substring(7)
        if ($file -and (Test-Path $file -PathType Container)) { $file = Join-Path $file 'index.html' }
      } elseif ($path -eq '/' -or $path -eq '/index.html') {
        $file = Join-Path $UiDir 'index.html'
      } else {
        $file = Resolve-Safe $UiDir $path
      }

      if ($file -and (Test-Path $file -PathType Leaf)) {
        $ext = [System.IO.Path]::GetExtension($file).ToLower()
        $res.ContentType = if ($Mime.ContainsKey($ext)) { $Mime[$ext] } else { 'application/octet-stream' }
        $bytes = [System.IO.File]::ReadAllBytes($file)
        $res.ContentLength64 = $bytes.Length
        $res.OutputStream.Write($bytes, 0, $bytes.Length)
      } else {
        $res.StatusCode = 404
        $b = [Text.Encoding]::UTF8.GetBytes('Not found')
        $res.OutputStream.Write($b, 0, $b.Length)
      }
    }
  } catch {
    try {
      $res.StatusCode = 500
      $b = [Text.Encoding]::UTF8.GetBytes('Server error: ' + $_.Exception.Message)
      $res.OutputStream.Write($b, 0, $b.Length)
    } catch {}
  }
  try { $res.Close() } catch {}
}

$listener.Close()
