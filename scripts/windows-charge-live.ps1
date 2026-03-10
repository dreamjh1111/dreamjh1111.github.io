param(
  [double]$IntervalSeconds = 1,
  [int]$MaxSamples = 0
)

if ($IntervalSeconds -le 0) {
  Write-Error "IntervalSeconds must be greater than 0."
  exit 1
}

if ($MaxSamples -lt 0) {
  Write-Error "MaxSamples cannot be negative."
  exit 1
}

$ErrorActionPreference = "SilentlyContinue"
[Console]::InputEncoding = [System.Text.UTF8Encoding]::new($false)
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
$OutputEncoding = [Console]::OutputEncoding

function Get-ClassInstances {
  param(
    [string]$Namespace,
    [string]$ClassName
  )

  try {
    $instances = @(Get-CimInstance -Namespace $Namespace -ClassName $ClassName)
    if ($instances.Count -gt 0) {
      return $instances
    }
  } catch {
  }

  $wmiCommand = Get-Command Get-WmiObject -ErrorAction SilentlyContinue
  if ($null -eq $wmiCommand) {
    return @()
  }

  try {
    return @(Get-WmiObject -Namespace $Namespace -Class $ClassName)
  } catch {
    return @()
  }
}

function Get-PrimaryInstance {
  param(
    [string]$Namespace,
    [string]$ClassName
  )

  $instances = @(Get-ClassInstances -Namespace $Namespace -ClassName $ClassName)
  if (-not $instances) {
    return $null
  }

  return $instances | Select-Object -First 1
}

function Get-BatteryStatusInstance {
  $instances = @(Get-ClassInstances -Namespace "root\wmi" -ClassName "BatteryStatus")
  if (-not $instances) {
    return $null
  }

  $primary = $instances |
    Where-Object {
      $_.Active -eq $true -or
      $_.PowerOnline -eq $true -or
      (To-DoubleOrNull $_.Voltage) -gt 0
    } |
    Select-Object -First 1

  if ($null -ne $primary) {
    return $primary
  }

  return $instances | Select-Object -First 1
}

function To-DoubleOrNull {
  param($Value)

  if ($null -eq $Value -or $Value -eq "") {
    return $null
  }

  try {
    return [double]$Value
  } catch {
    return $null
  }
}

function To-KoreanYesNo {
  param($Value)

  if ($Value -eq $true) { return "예" }
  if ($Value -eq $false) { return "아니오" }
  return "-"
}

function To-KoreanBatteryCondition {
  param([string]$Value)

  switch ($Value) {
    "OK" { return "정상" }
    "Degraded" { return "성능 저하" }
    "Pred Fail" { return "고장 예측" }
    default {
      if ([string]::IsNullOrWhiteSpace($Value)) {
        return "-"
      }
      return $Value
    }
  }
}

function To-KoreanChargeState {
  param(
    $Status,
    $PortableBattery
  )

  if ($null -ne $Status) {
    if ($Status.Charging -eq $true) { return "충전 중" }
    if ($Status.Discharging -eq $true) { return "배터리 사용 중" }
    if ($Status.PowerOnline -eq $true) { return "충전 안 함" }
  }

  if ($null -ne $PortableBattery) {
    switch ([int]$PortableBattery.BatteryStatus) {
      1 { return "배터리 사용 중" }
      2 { return "외부 전원 사용 중" }
      3 { return "완전 충전" }
      6 { return "충전 중" }
      7 { return "충전 중" }
      8 { return "충전 중" }
      9 { return "충전 중" }
      11 { return "부분 충전" }
      default { return "-" }
    }
  }

  return "-"
}

function Format-ScaledValue {
  param(
    [double]$Value,
    [double]$Divisor,
    [int]$Decimals
  )

  return [math]::Round(($Value / $Divisor), $Decimals).ToString("F$Decimals")
}

function Format-Percent {
  param(
    [double]$Value,
    [int]$Decimals = 1
  )

  return [math]::Round($Value, $Decimals).ToString("F$Decimals")
}

function Format-ValueOrUnknown {
  param(
    $Value,
    [string]$Suffix = ""
  )

  if ($null -eq $Value -or $Value -eq "") {
    return "-"
  }

  return "$Value$Suffix"
}

function Format-WattsOrUnknown {
  param($Value)

  if ($null -eq $Value -or $Value -eq "") {
    return "-"
  }

  return "$(Format-Percent -Value $Value -Decimals 2) W"
}

function Format-AmpsOrUnknown {
  param(
    $Value,
    [switch]$Estimated
  )

  if ($null -eq $Value -or $Value -eq "") {
    return "-"
  }

  $label = "$(Format-Percent -Value $Value -Decimals 3) A"
  if ($Estimated) {
    return "$label (배터리 전력/전압 기반 추정)"
  }

  return $label
}

function Get-SignedBatteryCurrentA {
  param(
    [double]$ChargeWatts,
    [double]$DischargeWatts,
    [double]$VoltageMv
  )

  if ($VoltageMv -le 0) {
    return $null
  }

  $voltageV = $VoltageMv / 1000
  if ($voltageV -le 0) {
    return $null
  }

  $chargeCurrentA = 0
  $dischargeCurrentA = 0

  if ($ChargeWatts -gt 0) {
    $chargeCurrentA = $ChargeWatts / $voltageV
  }

  if ($DischargeWatts -gt 0) {
    $dischargeCurrentA = $DischargeWatts / $voltageV
  }

  return $chargeCurrentA - $dischargeCurrentA
}

$sampleCount = 0

while ($true) {
  $batteryStatus = Get-BatteryStatusInstance
  $batteryStatic = Get-PrimaryInstance -Namespace "root\wmi" -ClassName "BatteryStaticData"
  $batteryFull = Get-PrimaryInstance -Namespace "root\wmi" -ClassName "BatteryFullChargedCapacity"
  $batteryCycle = Get-PrimaryInstance -Namespace "root\wmi" -ClassName "BatteryCycleCount"
  $portableBattery = Get-PrimaryInstance -Namespace "root\cimv2" -ClassName "Win32_Battery"

  $remainingCapacity = $null
  $fullChargedCapacity = $null
  $designedCapacity = $null
  $batteryVoltageMv = $null
  $chargeRateMw = $null
  $dischargeRateMw = $null
  $batteryLevelPercent = $null
  $healthPercent = $null
  $wearPercent = $null
  $cycleCount = $null
  $powerOnline = $null
  $fullyCharged = $null
  $batteryCondition = $null

  if ($null -ne $batteryStatus) {
    $remainingCapacity = To-DoubleOrNull $batteryStatus.RemainingCapacity
    $batteryVoltageMv = To-DoubleOrNull $batteryStatus.Voltage
    $powerOnline = $batteryStatus.PowerOnline

    $rawChargeRate = To-DoubleOrNull $batteryStatus.ChargeRate
    $rawDischargeRate = To-DoubleOrNull $batteryStatus.DischargeRate

    if ($rawChargeRate -gt 0) {
      $chargeRateMw = $rawChargeRate
    }

    if ($rawDischargeRate -gt 0) {
      $dischargeRateMw = $rawDischargeRate
    }
  }

  if ($null -ne $batteryFull) {
    $fullChargedCapacity = To-DoubleOrNull $batteryFull.FullChargedCapacity
  }

  if ($null -ne $batteryStatic) {
    $designedCapacity = To-DoubleOrNull $batteryStatic.DesignedCapacity
  }

  if ($null -ne $batteryCycle) {
    $cycleCount = $batteryCycle.CycleCount
  }

  if ($null -ne $portableBattery) {
    if ($null -eq $batteryLevelPercent -and $portableBattery.EstimatedChargeRemaining -ne $null) {
      $batteryLevelPercent = To-DoubleOrNull $portableBattery.EstimatedChargeRemaining
    }
    $batteryCondition = $portableBattery.Status
  }

  if ($null -eq $batteryLevelPercent -and $remainingCapacity -ne $null -and $fullChargedCapacity -gt 0) {
    $batteryLevelPercent = [math]::Min(100, (($remainingCapacity / $fullChargedCapacity) * 100))
  }

  if ($designedCapacity -gt 0 -and $fullChargedCapacity -gt 0) {
    $healthPercent = ($fullChargedCapacity / $designedCapacity) * 100
    $wearPercent = [math]::Max(0, (100 - $healthPercent))
  }

  if ($null -ne $batteryLevelPercent) {
    $fullyCharged = ($batteryLevelPercent -ge 99.5)
  }

  $batteryChargeW = 0
  $batteryDischargeW = 0
  $batteryNetW = $null
  $batteryCurrentA = $null

  if ($chargeRateMw -gt 0) {
    $batteryChargeW = $chargeRateMw / 1000
  }

  if ($dischargeRateMw -gt 0) {
    $batteryDischargeW = $dischargeRateMw / 1000
  }

  if ($chargeRateMw -gt 0 -or $dischargeRateMw -gt 0) {
    $batteryNetW = $batteryChargeW - $batteryDischargeW
  }

  if ($batteryVoltageMv -gt 0) {
    $batteryCurrentA = Get-SignedBatteryCurrentA -ChargeWatts $batteryChargeW -DischargeWatts $batteryDischargeW -VoltageMv $batteryVoltageMv
  }

  Clear-Host
  Write-Host "Windows 배터리 모니터"
  Write-Host "업데이트: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
  Write-Host ""

  $powerStatusLines = @()
  if ($powerOnline -ne $null) {
    $powerStatusLines += "외부 전원 연결: $(To-KoreanYesNo $powerOnline)"
  }
  $chargeState = To-KoreanChargeState -Status $batteryStatus -PortableBattery $portableBattery
  if ($chargeState -ne "-") {
    $powerStatusLines += "배터리 충전 상태: $chargeState"
  }
  if ($fullyCharged -ne $null) {
    $powerStatusLines += "완전 충전 여부: $(To-KoreanYesNo $fullyCharged)"
  }
  if ($batteryLevelPercent -ne $null) {
    $powerStatusLines += "배터리 잔량: $(Format-Percent -Value $batteryLevelPercent -Decimals 0)%"
  }
  $batteryConditionText = To-KoreanBatteryCondition $batteryCondition
  if ($batteryConditionText -ne "-") {
    $powerStatusLines += "배터리 상태: $batteryConditionText"
  }
  if ($cycleCount -ne $null -and $cycleCount -ne "") {
    $powerStatusLines += "사이클 수: $cycleCount"
  }
  if ($healthPercent -ne $null) {
    $powerStatusLines += "배터리 건강도: $(Format-Percent -Value $healthPercent)% (Windows 배터리 WMI 기준)"
  }
  if ($wearPercent -ne $null) {
    $powerStatusLines += "배터리 웨어율: $(Format-Percent -Value $wearPercent)%"
  }
  if ($designedCapacity -ne $null) {
    $powerStatusLines += "설계 용량: $designedCapacity mWh"
  }
  if ($fullChargedCapacity -ne $null) {
    $powerStatusLines += "현재 최대 충전 용량: $fullChargedCapacity mWh"
  }
  if ($powerStatusLines.Count -gt 0) {
    Write-Host "[전원 상태]"
    $powerStatusLines | ForEach-Object { Write-Host $_ }
    Write-Host ""
  }

  $batteryPowerLines = @(
    "배터리 충전 전력: $(Format-Percent -Value $batteryChargeW -Decimals 2) W",
    "배터리 방전 전력: $(Format-Percent -Value $batteryDischargeW -Decimals 2) W"
  )
  if ($batteryNetW -ne $null) {
    $batteryPowerLines += "배터리 순전력: $(Format-Percent -Value $batteryNetW -Decimals 2) W"
  }
  Write-Host "[배터리 전력]"
  $batteryPowerLines | ForEach-Object { Write-Host $_ }
  Write-Host ""

  $liveMetricLines = @()
  if ($batteryCurrentA -ne $null) {
    $liveMetricLines += "배터리 전류: $(Format-AmpsOrUnknown -Value $batteryCurrentA -Estimated)"
  }
  if ($batteryVoltageMv -gt 0) {
    $liveMetricLines += "배터리 전압: $(Format-ScaledValue -Value $batteryVoltageMv -Divisor 1000 -Decimals 3) V"
  }
  if ($batteryNetW -ne $null) {
    $liveMetricLines += "배터리 전력 텔레메트리: $(Format-Percent -Value $batteryNetW -Decimals 2) W"
  }
  if ($liveMetricLines.Count -gt 0) {
    Write-Host "[실시간 수치]"
    $liveMetricLines | ForEach-Object { Write-Host $_ }
    Write-Host ""
  }

  Write-Host "참고: 이 스크립트는 순수 Windows 기본 인터페이스만 사용합니다."
  Write-Host "참고: 따라서 배터리 측 전력/전압은 볼 수 있지만, 어댑터 측 전압/전류/PD 협상값은 볼 수 없습니다."

  $sampleCount += 1
  if ($MaxSamples -gt 0 -and $sampleCount -ge $MaxSamples) {
    break
  }

  Start-Sleep -Seconds $IntervalSeconds
}
