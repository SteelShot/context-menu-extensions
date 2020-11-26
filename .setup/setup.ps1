#Requires -RunAsAdministrator

# Installer Functions
Function PromptYesNo {
    Param (
        [Parameter(Mandatory = $true)][String]$Message
    )

    $Choices = "&Yes", "&No"

    $Host.UI.PromptForChoice($null, $Message, $Choices, 1)
}

Function Print {
    Param (
        [Parameter(Mandatory = $true)][String]$M,
        [Parameter(Mandatory = $true)][String]$C 
    )

    Write-Host $M -ForegroundColor $C
}

Function Leave {
    Print -M "`nPress any key to continue..." -C DarkMagenta
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

    exit
}

Function Install {
    Print -M "Installing Context Menu Extensions" -C DarkGray

    # Install
    Start-Process "reg" -ArgumentList "import .\.setup\install.reg"

    if ( ((PromptYesNo -Message "`nInstall Extension: `"Console Prompts`"?") -eq 0)) {
        InstallConsoleExtensions
    }

    Print -M "`nInstalled Context Menu Extensions" -C Green

    Leave
}

Function Uninstall {
    Start-Process "reg" -ArgumentList "import .\.setup\uninstall.reg"
    Print -M "`nUninstalled Context Menu Extensions" -C DarkRed
}

Function InstallConsoleExtensions {
    Print -M "`nInstalling: Console Prompts" -C DarkGray

    # Install
    Start-Process "reg" -ArgumentList "import .\extensions\console\.setup\install.reg"
    
    # cmd
    Start-Process "reg" -ArgumentList "import .\extensions\console\cmd.reg"

    # powershell
    Start-Process "reg" -ArgumentList "import .\extensions\console\powershell.reg"

    # pwsh
    if (Get-Command "pwsh.exe" -ErrorAction SilentlyContinue) {
        Start-Process "reg" -ArgumentList "import .\extensions\console\pwsh.reg"
    }

    Print -M "Installed: Console Prompts" -C Green
}

# Installer Start
$null = Clear-Host
Print -M "Context Menu Extensions 1.0.0" -C DarkMagenta

if (Test-Path -Path "HKLM:\SOFTWARE\Classes\Directory\ContextMenuExtensions") {
    Print -M "`nContext Menu Extensions are already installed!`nPlease run uninstaller before installing!" -C DarkRed

    if ((PromptYesNo -Message "`nWould you like to uninstall Console Prompt Extensions?") -eq 0) {
        Uninstall
    }

    Leave
}

if ( -Not ((PromptYesNo -Message "`nInstall?") -eq 0)) {
    Leave
}

Install