#Requires -Version 5.1
<#
.SYNOPSIS
    Install LazyVim on Windows with a set of personal customisations.
.DESCRIPTION
    Uses winget to install Neovim and LazyVim's recommended dependencies,
    clones the LazyVim starter into %LOCALAPPDATA%\nvim, then layers on the
    custom plugin/keymap files that live alongside this script.
#>

$ErrorActionPreference = "Stop"

# $PSScriptRoot is the reliable way to find the script's own directory in
# PS 5.1+. $MyInvocation.MyCommand.Definition can resolve to an empty/relative
# value depending on how the script is launched, which breaks the file copies.
$ScriptDir   = $PSScriptRoot
if (-not $ScriptDir) { $ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path }
$NvimConfig  = Join-Path $env:LOCALAPPDATA "nvim"
$NvimData    = Join-Path $env:LOCALAPPDATA "nvim-data"
$Timestamp   = Get-Date -Format "yyyyMMdd-HHmmss"
# When run as a standalone download (no repo alongside it), the script fetches
# its custom files from here instead.
$RepoRawBase = "https://raw.githubusercontent.com/dombean/ansible/main/lazyvim"

function Update-SessionPath {
    # Pick up tools installed by winget without reopening the terminal.
    $machine = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $user    = [System.Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = "$machine;$user"
}

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw "winget not found. Install 'App Installer' from the Microsoft Store, then re-run this script."
}

function Install-WingetPackage {
    param([string]$Id, [string]$CommandCheck, [switch]$Optional)

    # If the tool is already on PATH, there is nothing to do. This keeps the
    # script idempotent and avoids winget's non-zero "already installed" exit
    # codes (which also occur on CI runners that ship git, etc.).
    if ($CommandCheck -and (Get-Command $CommandCheck -ErrorAction SilentlyContinue)) {
        Write-Host "==> $Id already available ('$CommandCheck' found), skipping"
        return
    }

    Write-Host "==> Installing $Id"
    winget install --id $Id --exact --silent `
        --accept-package-agreements --accept-source-agreements

    # winget returns non-zero when a package is already installed or no newer
    # version is applicable; treat those as success.
    #   -1978335189 = 0x8A15002B  no applicable upgrade
    #   -1978335135 = 0x8A150061  package already installed
    $benignCodes = @(0, -1978335189, -1978335135)
    if ($benignCodes -notcontains $LASTEXITCODE) {
        if ($Optional) {
            Write-Warning "Could not install $Id (winget exit $LASTEXITCODE) - install it manually if needed."
        } else {
            throw "Failed to install $Id (winget exit code $LASTEXITCODE)."
        }
    }
}

Write-Host "==> Installing Neovim and LazyVim dependencies"
Install-WingetPackage -Id "Git.Git"                  -CommandCheck "git"
Install-WingetPackage -Id "Neovim.Neovim"            -CommandCheck "nvim"
Install-WingetPackage -Id "BurntSushi.ripgrep.MSVC"  -CommandCheck "rg"
Install-WingetPackage -Id "sharkdp.fd"               -CommandCheck "fd"
Install-WingetPackage -Id "junegunn.fzf"             -CommandCheck "fzf"
Install-WingetPackage -Id "JesseDuffield.lazygit"    -CommandCheck "lazygit"
# C compiler (gcc) for nvim-treesitter. This is the exact package LazyVim's
# own health check recommends; WinLibs is a portable MinGW-w64 toolchain that
# winget exposes on PATH via its Links shim directory, so `gcc` is detected
# without the MSVC toolchain/Windows SDK that a clang-only install needs.
Install-WingetPackage -Id "BrechtSanders.WinLibs.POSIX.UCRT" -CommandCheck "gcc"
# A Nerd Font for icons - id varies across winget versions, so treat as optional.
Install-WingetPackage -Id "DEVCOM.JetBrainsMonoNerdFont" -Optional

Update-SessionPath

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "git is still not on PATH. Open a new terminal and re-run this script."
}

# Back up any existing Neovim configuration / data so nothing is lost.
function Backup-Path {
    param([string]$Path)
    if (Test-Path $Path) {
        $backup = "$Path.bak.$Timestamp"
        Write-Host "==> Backing up $Path -> $backup"
        Move-Item -Path $Path -Destination $backup
    }
}

Write-Host "==> Backing up existing Neovim config/data (if any)"
Backup-Path -Path $NvimConfig
Backup-Path -Path $NvimData

Write-Host "==> Cloning the LazyVim starter"
git clone https://github.com/LazyVim/starter $NvimConfig
Remove-Item -Path (Join-Path $NvimConfig ".git") -Recurse -Force

Write-Host "==> Copying custom plugin files"
$PluginsDest = Join-Path $NvimConfig "lua\plugins"
New-Item -ItemType Directory -Force -Path $PluginsDest | Out-Null
$PluginsSrc  = Join-Path $ScriptDir "nvim\lua\plugins"
if (Test-Path (Join-Path $PluginsSrc "*.lua")) {
    Copy-Item -Path (Join-Path $PluginsSrc "*.lua") -Destination $PluginsDest
} else {
    Write-Host "    local source not found, downloading from GitHub"
    $PluginFiles = @("auto-save.lua", "hardtime.lua", "noice.lua", "snacks.lua", "surround.lua")
    foreach ($file in $PluginFiles) {
        Invoke-WebRequest -Uri "$RepoRawBase/nvim/lua/plugins/$file" `
            -OutFile (Join-Path $PluginsDest $file) -UseBasicParsing
    }
}

Write-Host "==> Adding auto-centring cursor keymaps"
$KeymapsFile = Join-Path $NvimConfig "lua\config\keymaps.lua"
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $KeymapsFile) | Out-Null
if (-not (Test-Path $KeymapsFile)) { New-Item -ItemType File -Path $KeymapsFile | Out-Null }
if (Select-String -Path $KeymapsFile -Pattern "custom: auto-centring cursor" -Quiet) {
    Write-Host "    keymaps already present, skipping"
} else {
    $SnippetLocal = Join-Path $ScriptDir "keymaps-snippet.lua"
    if (Test-Path $SnippetLocal) {
        $Snippet = Get-Content -Path $SnippetLocal -Raw
    } else {
        Write-Host "    local snippet not found, downloading from GitHub"
        $Snippet = (Invoke-WebRequest -Uri "$RepoRawBase/keymaps-snippet.lua" -UseBasicParsing).Content
    }
    Add-Content -Path $KeymapsFile -Value ""
    Add-Content -Path $KeymapsFile -Value $Snippet
}

Write-Host "==> Configuring PowerShell 7 as the built-in terminal shell (Windows)"
$OptionsFile = Join-Path $NvimConfig "lua\config\options.lua"
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $OptionsFile) | Out-Null
if (-not (Test-Path $OptionsFile)) { New-Item -ItemType File -Path $OptionsFile | Out-Null }
if (Select-String -Path $OptionsFile -Pattern "Windows: use PowerShell 7" -Quiet) {
    Write-Host "    PowerShell shell options already present, skipping"
} else {
    # Single-quoted here-string: the contents are written verbatim, so Lua
    # tokens like $_, %s and \" are not touched by PowerShell.
    $OptionsSnippet = @'
-- Windows: use PowerShell 7 (latest powershell) for the built-in terminal
if vim.fn.has("win32") == 1 then
  vim.opt.shell = "pwsh"
  vim.opt.shellcmdflag = "-NoLogo -NonInteractive -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
  vim.opt.shellredir = "2>&1 | %%{ \"$_\" } | Out-File %s; exit $LastExitCode"
  vim.opt.shellpipe  = "2>&1 | %%{ \"$_\" } | Tee-Object %s; exit $LastExitCode"
  vim.opt.shellquote = ""
  vim.opt.shellxquote = ""
end
'@
    Add-Content -Path $OptionsFile -Value ""
    Add-Content -Path $OptionsFile -Value $OptionsSnippet
}

Write-Host @"

==> Done!

LazyVim is installed with your customisations:
  - auto-save.nvim
  - noice.nvim disabled
  - hardtime.nvim
  - nvim-surround
  - auto-centring cursor keymaps
  - PowerShell 7 as the built-in terminal shell (Windows)

Next steps:
  1. Open a NEW terminal (so PATH updates take effect).
  2. Launch Neovim:  nvim
  3. Wait for plugins to install, then run:  :Lazy sync
  4. Set your terminal font to a Nerd Font (e.g. JetBrainsMono Nerd Font) for icons.
"@
