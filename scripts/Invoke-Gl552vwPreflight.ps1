<#
.SYNOPSIS
  Read-only preflight checks for the WDDM2-on-Windows-7 GL552VW guide kit.
.DESCRIPTION
  Reports OS build, display adapters with hardware IDs, RAM and free disk space.
  With -DriverFolder, searches extracted driver INFs for this machine's GPU
  hardware IDs so you can confirm a package supports your GPUs before installing.
  Changes nothing on the system.
.EXAMPLE
  .\Invoke-Gl552vwPreflight.ps1
.EXAMPLE
  .\Invoke-Gl552vwPreflight.ps1 -DriverFolder "C:\Drivers\WDDM2\NVIDIA"
#>
[CmdletBinding()]
param(
  [string]$DriverFolder
)

$ErrorActionPreference = 'Continue'
function Step($t) { Write-Host "`n== $t ==" -ForegroundColor Cyan }
function Good($t) { Write-Host "  [ OK ] $t" -ForegroundColor Green }
function Warn($t) { Write-Host "  [ !! ] $t" -ForegroundColor Yellow }
function Info($t) { Write-Host "  $t" }

Step 'Operating system'
$os = Get-CimInstance Win32_OperatingSystem
Info "$($os.Caption) (build $($os.BuildNumber), $($os.OSArchitecture))"
if ($os.BuildNumber -eq '7601') { Good 'Windows 7 SP1 build 7601 detected.' }
elseif ($os.BuildNumber -eq '7600') { Warn 'Windows 7 RTM (7600). Install Service Pack 1 and updates first.' }
else { Warn "Not Windows 7 SP1 (build $($os.BuildNumber)). This guide targets Windows 7 SP1 x64 only." }

Step 'Memory and free disk space'
$ramGb = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 1)
Info "RAM: $ramGb GB (guide laptop: 24 GB)"
$sys = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='$($env:SystemDrive)'"
$freeGb = [math]::Round($sys.FreeSpace / 1GB, 1)
if ($freeGb -ge 10) { Good "Free space on $($env:SystemDrive): $freeGb GB" } else { Warn "Only $freeGb GB free on $($env:SystemDrive). Free at least 10 GB before driver work." }

Step 'Display adapters and hardware IDs'
$ids = @()
foreach ($gpu in Get-CimInstance Win32_VideoController) {
  Info "$($gpu.Name)"
  Info "  PNPDeviceID: $($gpu.PNPDeviceID)"
  Info "  Driver: $($gpu.DriverVersion) ($($gpu.DriverDate))"
  if ($gpu.PNPDeviceID -match '(VEN_[0-9A-F]{4}&DEV_[0-9A-F]{4})') { $ids += $Matches[1] }
}
if ($ids -contains 'VEN_8086&DEV_191B') { Good 'Intel HD Graphics 530 (8086:191B) found - use the Intel HD Skylake package.' }
if ($ids | Where-Object { $_ -like 'VEN_10DE*' }) { Good "NVIDIA GPU found ($($ids | Where-Object { $_ -like 'VEN_10DE*' })). Verify this exact ID in the NVIDIA package INF before installing." }
if (-not $ids) { Warn 'No display adapter hardware IDs detected. Run on the target laptop, not over a remote session without GPU passthrough.' }

if ($DriverFolder) {
  Step "INF support check: $DriverFolder"
  if (-not (Test-Path $DriverFolder)) {
    Warn 'Folder not found. Extract the driver .7z first, then re-run with the extracted path.'
  } else {
    $infs = Get-ChildItem $DriverFolder -Recurse -Filter *.inf -ErrorAction SilentlyContinue
    if (-not $infs) {
      Warn 'No .inf files under that folder. Point -DriverFolder at the extracted driver directory.'
    } else {
      Info "Searching $($infs.Count) INF file(s)..."
      foreach ($id in $ids) {
        $hits = $infs | Select-String -SimpleMatch $id -List -ErrorAction SilentlyContinue
        if ($hits) { Good "$id listed in: $(($hits | ForEach-Object { Split-Path $_.Path -Leaf }) -join ', ')" }
        else { Warn "$id NOT found in any INF. Do not force-install this package for that GPU." }
      }
    }
  }
}

Step 'Reminders'
Info 'Create a System Restore point / disk image before installing anything.'
Info 'Install order: main package -> reboot -> Intel driver -> reboot -> NVIDIA driver.'
Info 'After the NVIDIA backport driver: leave resolution at native 1920x1080.'
