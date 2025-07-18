$repoUrl = "https://github.com/your-org/nebctl.git"
$installDir = "$env:USERPROFILE\.nebctl"
$binDir = "$env:USERPROFILE\AppData\Local\Microsoft\WindowsApps"
$entryScript = "nebctl\nebctl.py"
$shimPath = "$binDir\nebctl.cmd"

function Print-Step($msg) {
    Write-Host "`n$msg"
}

function Ensure-Python {
    $python = Get-Command python -ErrorAction SilentlyContinue
    if (-not $python) {
        Write-Error "Python is not installed. Please install Python 3.8 or newer."
        exit 1
    }
    $version = & python -c "import sys; print('.'.join(map(str, sys.version_info[:2])))"
    $versionParts = $version.Split('.')
    $major = [int]$versionParts[0]
    $minor = [int]$versionParts[1]
    if ($major -lt 3 -or ($major -eq 3 -and $minor -lt 8)) {
        Write-Error "Python version $version is too old. Please upgrade to Python 3.8+."
        exit 1
    }
    Write-Host "Python $version found."
}

function Ensure-Git {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Error "Git is required. Please install Git and re-run."
        exit 1
    }
}

function Clone-Or-Update-Repo {
    if (Test-Path "$installDir\.git") {
        Print-Step "Updating nebctl repo..."
        Push-Location $installDir
        git pull
        Pop-Location
    } else {
        Print-Step "Cloning nebctl repo..."
        git clone $repoUrl $installDir
    }
}

function Create-Symlink {
    if (-not (Test-Path $binDir)) {
        New-Item -ItemType Directory -Path $binDir | Out-Null
    }
    $shim = "@echo off`r`npython `"$installDir\$entryScript`" %*"
    Set-Content -Path $shimPath -Value $shim -Encoding ASCII
    Write-Host "Created shim at $shimPath"
}

function Ensure-Kubectl {
    if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
        Print-Step "Installing kubectl using Chocolatey..."
        if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
            Write-Warning "Chocolatey not found. Please install kubectl manually."
            return
        }
        choco install -y kubernetes-cli
    } else {
        Write-Host "kubectl already installed."
    }
}

function Ensure-NPC {
    if (-not (Get-Command npc -ErrorAction SilentlyContinue)) {
        Print-Step "Installing npc..."
        $npcScript = "$env:TEMP\install_npc.ps1"
        Invoke-WebRequest -Uri "https://artifactory.nebius.dev/artifactory/npc/install.ps1" -OutFile $npcScript
        powershell -ExecutionPolicy Bypass -File $npcScript
    } else {
        Write-Host "npc already installed."
    }
}

function Check-ProdSA {
    $prodPath = "$env:USERPROFILE\.config\nebctl\profiles\prod-sa.yaml"
    if (-not (Test-Path $prodPath)) {
        $response = Read-Host "prod-sa profile not found. Would you like to set it up? [Y/n]"
        if ($response -eq "Y" -or $response -eq "" -or $response -eq "y") {
            Write-Host "Future feature coming soon"
        } else {
            Write-Host "Continuing without prod-sa. Use --profile flag as needed."
        }
    }
}

function Install-Requirements {
    $reqFile = "$installDir\requirements.txt"
    if (Test-Path $reqFile) {
        Write-Host "Installing Python requirements..."
        & python -m pip install --user -r $reqFile
    }
}

function Main {
    Ensure-Git
    Ensure-Python
    Clone-Or-Update-Repo
    Create-Symlink
    Ensure-Kubectl
    Ensure-NPC
    Check-ProdSA
    Install-Requirements
    Write-Host "nebctl installed successfully. Open a new terminal and run 'nebctl --version'"
}

Main
