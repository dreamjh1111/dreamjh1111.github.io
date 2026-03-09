param(
  [double]$IntervalSeconds = 1
)

$ErrorActionPreference = "SilentlyContinue"

function Get-PrimaryCimInstance {
  param(
    [string]$Namespace,
    [string]$ClassName
  )

  try {
    $instances = Get-CimInstance -Namespace $Namespace -ClassName $ClassName
    if ($null -eq $instances) {
      return $null
    }

    if ($instances -is [array]) {
      return $instances | Select-Object -First 1
    }

    return $instances
  } catch {
    return $null
  }
}

function Get-BatteryStatusInstance {
  try {
    $instances = @(Get-CimInstance -Namespace "root\wmi" -ClassName "BatteryStatus")
    if (-not $instances) {
      return $null
    }

    $primary = $instances | Where-Object { $_.Active -eq $true -or $_.Voltage -gt 0 } | Select-Object -First 1
    if ($null -ne $primary) {
      return $primary
    }

    return $instances | Select-Object -First 1
  } catch {
    return $null
  }
}

function To-KoreanYesNo {
  param($Value)

  if ($Value -eq $true) { return "예" }
  if ($Value -eq $false) { return "아니오" }
  return "알 수 없음"
}

function To-KoreanBatteryCondition {
  param([string]$Value)

  switch ($Value) {
    "OK" { return "정상" }
    "Degraded" { return "성능 저하" }
    "Pred Fail" { return "고장 예측" }
    default {
      if ([string]::IsNullOrWhiteSpace($Value)) {
        return "알 수 없음"
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
      default { return "알 수 없음" }
    }
  }

  return "알 수 없음"
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
    return "알 수 없음"
  }

  return "$Value$Suffix"
}

function Format-WattsOrUnknown {
  param($Value)

  if ($null -eq $Value -or $Value -eq "") {
    return "알 수 없음"
  }

  return "$(Format-Percent -Value $Value -Decimals 2) W"
}

while ($true) {
  $batteryStatus = Get-BatteryStatusInstance
  $batteryStatic = Get-PrimaryCimInstance -Namespace "root\wmi" -ClassName "BatteryStaticData"
  $batteryFull = Get-PrimaryCimInstance -Namespace "root\wmi" -ClassName "BatteryFullChargedCapacity"
  $batteryCycle = Get-PrimaryCimInstance -Namespace "root\wmi" -ClassName "BatteryCycleCount"
  $portableBattery = Get-PrimaryCimInstance -Namespace "root\cimv2" -ClassName "Win32_Battery"

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
  $charging = $null
  $discharging = $null
  $fullyCharged = $null
  $batteryCondition = $null

  if ($null -ne $batteryStatus) {
    $remainingCapacity = $batteryStatus.RemainingCapacity
    $batteryVoltageMv = $batteryStatus.Voltage
    $powerOnline = $batteryStatus.PowerOnline
    $charging = $batteryStatus.Charging
    $discharging = $batteryStatus.Discharging
    if ($batteryStatus.ChargeRate -gt 0) {
      $chargeRateMw = [double]$batteryStatus.ChargeRate
    }
    if ($batteryStatus.DischargeRate -gt 0) {
      $dischargeRateMw = [double]$batteryStatus.DischargeRate
    }
  }

  if ($null -ne $batteryFull) {
    $fullChargedCapacity = $batteryFull.FullChargedCapacity
  }

  if ($null -ne $batteryStatic) {
    $designedCapacity = $batteryStatic.DesignedCapacity
  }

  if ($null -ne $batteryCycle) {
    $cycleCount = $batteryCycle.CycleCount
  }

  if ($null -ne $portableBattery) {
    if ($null -eq $batteryLevelPercent -and $portableBattery.EstimatedChargeRemaining -ne $null) {
      $batteryLevelPercent = [double]$portableBattery.EstimatedChargeRemaining
    }
    $batteryCondition = $portableBattery.Status
  }

  if ($null -eq $batteryLevelPercent -and $remainingCapacity -ne $null -and $fullChargedCapacity -gt 0) {
    $batteryLevelPercent = [math]::Min(100, (($remainingCapacity / $fullChargedCapacity) * 100))
  }

  if ($designedCapacity -gt 0 -and $fullChargedCapacity -gt 0) {
    $healthPercent = ($fullChargedCapacity / $designedCapacity) * 100
    $wearPercent = 100 - $healthPercent
  }

  if ($null -ne $batteryLevelPercent) {
    $fullyCharged = ($batteryLevelPercent -ge 99.5)
  }

  $adapterInputW = $null
  $systemLoadW = $null
  $bypassW = $null
  $batteryChargeW = $null
  $batteryDischargeW = $null
  $batteryNetW = $null

  if ($chargeRateMw -gt 0) {
    $batteryChargeW = $chargeRateMw / 1000
    $batteryNetW = $batteryChargeW
  } else {
    $batteryChargeW = 0
  }

  if ($dischargeRateMw -gt 0) {
    $batteryDischargeW = $dischargeRateMw / 1000
    if ($batteryChargeW -gt 0) {
      $batteryNetW = $batteryChargeW - $batteryDischargeW
    } else {
      $batteryNetW = -1 * $batteryDischargeW
    }
  } else {
    $batteryDischargeW = 0
  }

  if ($powerOnline -eq $false) {
    $adapterInputW = 0
    $systemLoadW = $batteryDischargeW
    $bypassW = 0
  }

  Clear-Host
  Write-Host "Windows 충전 모니터"
  Write-Host "업데이트: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
  Write-Host ""

  Write-Host "[전원 상태]"
  Write-Host "외부 전원 연결: $(To-KoreanYesNo $powerOnline)"
  Write-Host "배터리 충전 상태: $(To-KoreanChargeState -Status $batteryStatus -PortableBattery $portableBattery)"
  Write-Host "완전 충전 여부: $(To-KoreanYesNo $fullyCharged)"
  if ($batteryLevelPercent -ne $null) {
    Write-Host "배터리 잔량: $(Format-Percent -Value $batteryLevelPercent -Decimals 0)%"
  } else {
    Write-Host "배터리 잔량: 알 수 없음"
  }
  Write-Host "배터리 상태: $(To-KoreanBatteryCondition $batteryCondition)"
  Write-Host "사이클 수: $(Format-ValueOrUnknown $cycleCount)"
  if ($healthPercent -ne $null) {
    Write-Host "배터리 건강도: $(Format-Percent -Value $healthPercent)% (Windows 배터리 WMI 기준)"
    Write-Host "배터리 웨어율: $(Format-Percent -Value $wearPercent)%"
  } else {
    Write-Host "배터리 건강도: 알 수 없음"
    Write-Host "배터리 웨어율: 알 수 없음"
  }
  Write-Host "설계 용량: $(Format-ValueOrUnknown $designedCapacity ' mWh')"
  Write-Host "현재 최대 충전 용량: $(Format-ValueOrUnknown $fullChargedCapacity ' mWh')"

  Write-Host ""
  Write-Host "[전력 흐름]"
  Write-Host "어댑터 총 입력 전력: $(Format-WattsOrUnknown $adapterInputW)"
  Write-Host "시스템 전체 소비 전력: $(Format-WattsOrUnknown $systemLoadW)"
  Write-Host "직결 사용 전력(bypass): $(Format-WattsOrUnknown $bypassW)"
  Write-Host "배터리 충전 전력: $(Format-Percent -Value $batteryChargeW -Decimals 2) W"
  Write-Host "배터리 사용 전력: $(Format-Percent -Value $batteryDischargeW -Decimals 2) W"

  Write-Host ""
  Write-Host "[실시간 수치]"
  if ($powerOnline -eq $true) {
    Write-Host "어댑터 입력 전류: 알 수 없음 (표준 Windows WMI 미제공)"
    Write-Host "어댑터 입력 전압: 알 수 없음 (표준 Windows WMI 미제공)"
  } else {
    Write-Host "어댑터 입력 전류: 0.000 A"
    Write-Host "어댑터 입력 전압: 0.000 V"
  }
  if ($batteryStatus -ne $null -and $batteryVoltageMv -gt 0) {
    Write-Host "배터리 전류: 알 수 없음 (표준 Windows WMI 미제공)"
    Write-Host "배터리 전압: $(Format-ScaledValue -Value $batteryVoltageMv -Divisor 1000 -Decimals 3) V"
  } else {
    Write-Host "배터리 전류: 알 수 없음"
    Write-Host "배터리 전압: 알 수 없음"
  }
  if ($batteryNetW -ne $null) {
    Write-Host "배터리 순전력: $(Format-Percent -Value $batteryNetW -Decimals 2) W"
  } else {
    Write-Host "배터리 순전력: 알 수 없음"
  }
  Write-Host "배터리 전력 텔레메트리: $(Format-Percent -Value ($batteryChargeW - $batteryDischargeW) -Decimals 2) W"

  Write-Host ""
  Write-Host "[충전기 협상 프로필]"
  Write-Host "최대 전류: 알 수 없음 (표준 Windows WMI 미제공)"
  Write-Host "최대 전압: 알 수 없음 (표준 Windows WMI 미제공)"
  Write-Host "최대 전력: 알 수 없음 (표준 Windows WMI 미제공)"

  Write-Host ""
  Write-Host "참고: Windows 표준 배터리 WMI는 기기마다 제공 항목이 다릅니다."
  Write-Host "참고: 어댑터 총 입력 전력과 bypass 전력은 OEM 센서가 없으면 정확히 구할 수 없습니다."

  Start-Sleep -Seconds $IntervalSeconds
}
