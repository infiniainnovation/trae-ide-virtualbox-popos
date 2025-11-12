# Windows 11 Optimization Script for TRAE IDE VM
# Run as Administrator in PowerShell

Write-Host "🚀 Iniciando optimización de Windows 11 para TRAE IDE..." -ForegroundColor Cyan

# Verificar permisos de administrador
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "❌ Este script debe ejecutarse como Administrador" -ForegroundColor Red
    exit 1
}

# Desactivar servicios innecesarios
$servicesToDisable = @(
    "WSearch",           # Windows Search (consume muchos recursos)
    "SysMain",           # Superfetch (no útil en VMs)
    "DiagTrack",         # Diagnostics Tracking Service
    "DiagSvc",           # Diagnostic Execution Service
    "lfsvc",             # Geolocation Service
    "MapsBroker",        # Downloaded Maps Manager
    "PcaSvc",            # Program Compatibility Assistant Service
    "TrkWks",            # Distributed Link Tracking Client
    "WlanSvc",           # WLAN AutoConfig (no necesario en VM)
    "Wcmsvc"             # Windows Connection Manager
)

Write-Host "`n🔧 Desactivando servicios innecesarios..." -ForegroundColor Yellow
foreach ($service in $servicesToDisable) {
    try {
        Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
        Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
        Write-Host "  ✅ $service - Desactivado" -ForegroundColor Green
    }
    catch {
        Write-Host "  ⚠️  $service - No encontrado o error" -ForegroundColor Yellow
    }
}

# Desinstalar aplicaciones innecesarias
$appsToRemove = @(
    "Microsoft.BingNews",
    "Microsoft.BingWeather",
    "Microsoft.GamingApp",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.People",
    "Microsoft.PowerAutomateDesktop",
    "Microsoft.Todos",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.WindowsMaps",
    "Microsoft.Xbox*",
    "Microsoft.YourPhone",
    "Microsoft.Zune*",
    "*3dbuilder*",
    "*skypeapp*",
    "*office*"
)

Write-Host "`n🧹 Desinstalando aplicaciones innecesarias..." -ForegroundColor Yellow
foreach ($app in $appsToRemove) {
    $packages = Get-AppxPackage -AllUsers | Where-Object {$_.Name -like $app}
    foreach ($package in $packages) {
        try {
            Remove-AppxPackage -Package $package.PackageFullName -AllUsers -ErrorAction Stop
            Write-Host "  ✅ $($package.Name) - Desinstalado" -ForegroundColor Green
        }
        catch {
            Write-Host "  ⚠️  $($package.Name) - Error al desinstalar" -ForegroundColor Yellow
        }
    }
}

# Configurar rendimiento
Write-Host "`n⚡ Configurando opciones de rendimiento..." -ForegroundColor Yellow
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null
powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61
Write-Host "  ✅ Esquema de energía: Alto rendimiento" -ForegroundColor Green

# Desactivar efectos visuales
$systemProperties = @"
SetRegKey "HKCU:\Control Panel\Desktop" "UserPreferencesMask" ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00))
SetRegKey "HKCU:\Control Panel\Desktop" "DragFullWindows" "0"
SetRegKey "HKCU:\Control Panel\Desktop" "FontSmoothing" "0"
SetRegKey "HKCU:\Control Panel\Desktop" "FontSmoothingType" "0"
SetRegKey "HKCU:\Control Panel\Desktop\WindowMetrics" "MinAnimate" "0"
SetRegKey "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" "VisualFXSetting" "3"
SetRegKey "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" "DisableThumbnails" "1"
SetRegKey "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" "ShellState" ([byte[]](0x24,0x00,0x00,0x00,0x3C,0x28,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x13,0x00,0x00,0x00))
SetRegKey "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "IconsOnly" "1"
SetRegKey "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ListviewAlphaSelect" "0"
SetRegKey "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ListviewShadow" "0"
SetRegKey "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarAnimations" "0"
SetRegKey "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System" "DisableTaskMgr" "0"
SetRegKey "HKCU:\Control Panel\Accessibility\StickyKeys" "Flags" "506"
SetRegKey "HKCU:\Control Panel\Accessibility\ToggleKeys" "Flags" "58"
SetRegKey "HKCU:\Control Panel\Accessibility\Keyboard Response" "Flags" "122"
SetRegKey "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" "AutoRestartShell" "1"
function SetRegKey {
    param(
        [string]$Path,
        [string]$Name,
        $Value
    )
    
    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }
    
    Set-ItemProperty -Path $Path -Name $Name -Value $Value -Force
}
"@
Invoke-Expression $systemProperties
Write-Host "  ✅ Efectos visuales optimizados" -ForegroundColor Green

# Desactivar Windows Update temporalmente
Write-Host "`n⏳ Desactivando Windows Update temporalmente..." -ForegroundColor Yellow
Set-Service -Name "wuauserv" -StartupType Disabled -ErrorAction SilentlyContinue
Stop-Service -Name "wuauserv" -Force -ErrorAction SilentlyContinue
Write-Host "  ✅ Windows Update desactivado (reactiva después de 7 días)" -ForegroundColor Green

# Configurar SSH Server
Write-Host "`n🔐 Configurando OpenSSH Server..." -ForegroundColor Yellow
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0 -ErrorAction SilentlyContinue
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'
Write-Host "  ✅ OpenSSH Server configurado. Puedes conectarte desde Pop!_OS con:" -ForegroundColor Green
Write-Host "     ssh $env:USERNAME@localhost -p 2222" -ForegroundColor Cyan

# Crear carpeta para proyectos
$sharedFolder = "Z:\"
if (Test-Path $sharedFolder) {
    Write-Host "`n📁 Carpeta compartida detectada en $sharedFolder" -ForegroundColor Yellow
    if (-not (Test-Path "$sharedFolder\trae-projects")) {
        New-Item -Path "$sharedFolder\trae-projects" -ItemType Directory -Force | Out-Null
        Write-Host "  ✅ Carpeta de proyectos creada en $sharedFolder\trae-projects" -ForegroundColor Green
    }
}

# Mensaje final
Write-Host "`n🎉 ¡Optimización completada!" -ForegroundColor Cyan
Write-Host "`n✅ Pasos siguientes:" -ForegroundColor Yellow
Write-Host "1. Reinicia la VM para aplicar todos los cambios" -ForegroundColor White
Write-Host "2. Descarga e instala TRAE IDE desde https://www.trae.ai/" -ForegroundColor White
Write-Host "3. Configura TRAE con estos ajustes recomendados:" -ForegroundColor White
Write-Host "   - Settings → Performance: Reduce motion + Memory Limit 4096MB" -ForegroundColor White
Write-Host "   - Desactiva 'Git Blame' y 'Search in node_modules'" -ForegroundColor White
Write-Host "   - Builder Mode: Usa GPT-4o como modelo" -ForegroundColor White
Write-Host "4. ¡Empieza a desarrollar con TRAE IDE!" -ForegroundColor White

Write-Host "`n💡 Consejo: Crea un snapshot ahora mismo para tener un punto de recuperación rápido" -ForegroundColor Magenta
