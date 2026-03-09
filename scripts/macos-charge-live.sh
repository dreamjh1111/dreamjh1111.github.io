#!/bin/zsh

set -u

interval="${1:-1}"

if ! [[ "$interval" =~ '^[0-9]+([.][0-9]+)?$' ]]; then
  echo "사용법: $0 [갱신주기(초)]" >&2
  exit 1
fi

health_percent=""
health_source=""
battery_condition=""

extract_metrics() {
  ioreg -r -n AppleSmartBattery -w0 -l 2>/dev/null | perl -ne '
    if (/"ExternalConnected" = (Yes|No)/) { $v{external} = $1; }
    if (/"IsCharging" = (Yes|No)/) { $v{isCharging} = $1; }
    if (/"FullyCharged" = (Yes|No)/) { $v{fullyCharged} = $1; }
    if (/"CurrentCapacity" = (\d+)/) { $v{currentCapacity} = $1; }
    if (/"Voltage" = (\d+)/) { $v{batteryVoltage} = $1; }
    if (/"InstantAmperage" = (-?\d+)/) { $v{instantAmperage} = $1; }
    if (/"Amperage" = (-?\d+)/) { $v{amperage} = $1; }
    if (/"AdapterVoltage"=(\d+)/) { $v{adapterVoltage} = $1; }
    if (/"Current"=(\d+)/) { $v{adapterCurrent} = $1; }
    if (/"Watts"=(\d+)/) { $v{adapterWatts} = $1; }
    if (/"SystemCurrentIn"=(\d+)/) { $v{systemCurrentIn} = $1; }
    if (/"SystemVoltageIn"=(\d+)/) { $v{systemVoltageIn} = $1; }
    if (/"SystemPowerIn"=(\d+)/) { $v{systemPowerIn} = $1; }
    if (/"SystemLoad"=(\d+)/) { $v{systemLoad} = $1; }
    if (/"BatteryPower"=(\d+)/) { $v{batteryPowerTelemetry} = $1; }
    if (/"DesignCapacity" = (\d+)/) { $v{designCapacity} = $1; }
    if (/"NominalChargeCapacity" = (\d+)/) { $v{nominalChargeCapacity} = $1; }
    if (/"AppleRawMaxCapacity" = (\d+)/) { $v{rawMaxCapacity} = $1; }
    if (/"CycleCount" = (\d+)/) { $v{cycleCount} = $1; }
    END {
      for my $key (qw(
        external
        isCharging
        fullyCharged
        currentCapacity
        batteryVoltage
        instantAmperage
        amperage
        adapterVoltage
        adapterCurrent
        adapterWatts
        systemCurrentIn
        systemVoltageIn
        systemPowerIn
        systemLoad
        batteryPowerTelemetry
        designCapacity
        nominalChargeCapacity
        rawMaxCapacity
        cycleCount
      )) {
        my $value = exists $v{$key} ? $v{$key} : q{};
        print "$key=$value\n";
      }
    }
  '
}

read_health_metrics() {
  local profiler_output
  profiler_output="$(system_profiler SPPowerDataType 2>/dev/null)"

  if [[ -n "$profiler_output" ]]; then
    battery_condition="$(printf '%s\n' "$profiler_output" | perl -ne 'if (/Condition:\s+(.+)/) { print $1; exit }')"
    health_percent="$(printf '%s\n' "$profiler_output" | perl -ne 'if (/Maximum Capacity:\s+(\d+)%/) { print $1; exit }')"
    if [[ -n "$health_percent" ]]; then
      health_source="system"
    fi
  fi
}

to_fixed() {
  local value="$1"
  local divisor="$2"
  local decimals="$3"

  awk -v value="$value" -v divisor="$divisor" -v decimals="$decimals" '
    BEGIN {
      format = "%." decimals "f"
      printf format, value / divisor
    }
  '
}

calc_signed_power_w() {
  local current_ma="$1"
  local voltage_mv="$2"

  awk -v current_ma="$current_ma" -v voltage_mv="$voltage_mv" '
    BEGIN {
      printf "%.2f", (current_ma * voltage_mv) / 1000000
    }
  '
}

subtract_float() {
  local left="$1"
  local right="$2"

  awk -v left="$left" -v right="$right" '
    BEGIN {
      printf "%.2f", left - right
    }
  '
}

positive_float() {
  local value="$1"

  awk -v value="$value" '
    BEGIN {
      if (value < 0) {
        value = 0
      }
      printf "%.2f", value
    }
  '
}

negated_positive_float() {
  local value="$1"

  awk -v value="$value" '
    BEGIN {
      if (value < 0) {
        printf "%.2f", -value
      } else {
        printf "%.2f", 0
      }
    }
  '
}

calc_percent() {
  local numerator="$1"
  local denominator="$2"
  local decimals="${3:-1}"

  awk -v numerator="$numerator" -v denominator="$denominator" -v decimals="$decimals" '
    BEGIN {
      if (denominator == 0) {
        exit 1
      }
      format = "%." decimals "f"
      printf format, (numerator / denominator) * 100
    }
  '
}

yesno_ko() {
  case "$1" in
    Yes) echo "예" ;;
    No) echo "아니오" ;;
    *) echo "알 수 없음" ;;
  esac
}

charging_state_ko() {
  case "$1" in
    Yes) echo "충전 중" ;;
    No) echo "충전 안 함" ;;
    *) echo "알 수 없음" ;;
  esac
}

condition_ko() {
  case "$1" in
    Normal) echo "정상" ;;
    "Service Recommended") echo "서비스 권장" ;;
    Replace\ Soon) echo "곧 교체 권장" ;;
    Replace\ Now) echo "즉시 교체 권장" ;;
    *) echo "${1:-알 수 없음}" ;;
  esac
}

print_header() {
  printf '\033[2J\033[H'
  echo "macOS 충전 모니터"
  echo "업데이트: $(date '+%Y-%m-%d %H:%M:%S')"
  echo
}

read_health_metrics

while true; do
  external=""
  isCharging=""
  fullyCharged=""
  currentCapacity=""
  batteryVoltage=""
  instantAmperage=""
  amperage=""
  adapterVoltage=""
  adapterCurrent=""
  adapterWatts=""
  systemCurrentIn=""
  systemVoltageIn=""
  systemPowerIn=""
  systemLoad=""
  batteryPowerTelemetry=""
  designCapacity=""
  nominalChargeCapacity=""
  rawMaxCapacity=""
  cycleCount=""

  while IFS='=' read -r key value; do
    case "$key" in
      external) external="$value" ;;
      isCharging) isCharging="$value" ;;
      fullyCharged) fullyCharged="$value" ;;
      currentCapacity) currentCapacity="$value" ;;
      batteryVoltage) batteryVoltage="$value" ;;
      instantAmperage) instantAmperage="$value" ;;
      amperage) amperage="$value" ;;
      adapterVoltage) adapterVoltage="$value" ;;
      adapterCurrent) adapterCurrent="$value" ;;
      adapterWatts) adapterWatts="$value" ;;
      systemCurrentIn) systemCurrentIn="$value" ;;
      systemVoltageIn) systemVoltageIn="$value" ;;
      systemPowerIn) systemPowerIn="$value" ;;
      systemLoad) systemLoad="$value" ;;
      batteryPowerTelemetry) batteryPowerTelemetry="$value" ;;
      designCapacity) designCapacity="$value" ;;
      nominalChargeCapacity) nominalChargeCapacity="$value" ;;
      rawMaxCapacity) rawMaxCapacity="$value" ;;
      cycleCount) cycleCount="$value" ;;
    esac
  done < <(extract_metrics)

  battery_current_ma="${instantAmperage:-${amperage:-}}"
  battery_net_w="0.00"
  battery_charge_w="0.00"
  battery_discharge_w="0.00"
  adapter_input_w=""
  system_load_w=""
  bypass_w=""
  wear_percent=""
  health_display="$health_percent"
  health_note=""

  if [[ -n "${battery_current_ma:-}" && -n "${batteryVoltage:-}" ]]; then
    battery_net_w="$(calc_signed_power_w "$battery_current_ma" "$batteryVoltage")"
    battery_charge_w="$(positive_float "$battery_net_w")"
    battery_discharge_w="$(negated_positive_float "$battery_net_w")"
  fi

  if [[ -n "${systemPowerIn:-}" ]]; then
    adapter_input_w="$(to_fixed "$systemPowerIn" 1000 2)"
  fi

  if [[ -n "${systemLoad:-}" ]]; then
    system_load_w="$(to_fixed "$systemLoad" 1000 2)"
  elif [[ -n "${adapter_input_w:-}" ]]; then
    system_load_w="$(positive_float "$(subtract_float "$adapter_input_w" "$battery_charge_w")")"
  fi

  if [[ -n "${system_load_w:-}" ]]; then
    bypass_w="$(positive_float "$(subtract_float "$system_load_w" "$battery_discharge_w")")"
  elif [[ -n "${adapter_input_w:-}" ]]; then
    bypass_w="$(positive_float "$(subtract_float "$adapter_input_w" "$battery_charge_w")")"
  fi

  if [[ -z "$health_display" && -n "${nominalChargeCapacity:-}" && -n "${designCapacity:-}" ]]; then
    health_display="$(calc_percent "$nominalChargeCapacity" "$designCapacity" 1)"
    health_note=" (추정)"
  fi

  if [[ -n "${health_display:-}" ]]; then
    wear_percent="$(awk -v value="$health_display" 'BEGIN { printf "%.1f", 100 - value }')"
    if [[ "$health_source" == "system" ]]; then
      health_note=" (시스템 기준)"
    fi
  fi

  print_header

  echo "[전원 상태]"
  echo "외부 전원 연결: $(yesno_ko "$external")"
  echo "배터리 충전 상태: $(charging_state_ko "$isCharging")"
  echo "완전 충전 여부: $(yesno_ko "$fullyCharged")"
  echo "배터리 잔량: ${currentCapacity:-알 수 없음}%"
  echo "배터리 상태: $(condition_ko "${battery_condition:-}")"
  echo "사이클 수: ${cycleCount:-알 수 없음}"
  if [[ -n "${health_display:-}" ]]; then
    echo "배터리 건강도: ${health_display}%${health_note}"
  fi
  if [[ -n "${wear_percent:-}" ]]; then
    echo "배터리 웨어율: ${wear_percent}%"
  fi
  if [[ -n "${designCapacity:-}" ]]; then
    echo "설계 용량: ${designCapacity} mAh"
  fi
  if [[ -n "${nominalChargeCapacity:-}" ]]; then
    echo "현재 최대 충전 용량: ${nominalChargeCapacity} mAh"
  fi

  echo
  echo "[전력 흐름]"
  if [[ -n "${adapter_input_w:-}" ]]; then
    echo "어댑터 총 입력 전력: ${adapter_input_w} W"
  else
    echo "어댑터 총 입력 전력: 알 수 없음"
  fi
  if [[ -n "${system_load_w:-}" ]]; then
    echo "시스템 전체 소비 전력: ${system_load_w} W"
  else
    echo "시스템 전체 소비 전력: 알 수 없음"
  fi
  if [[ -n "${bypass_w:-}" ]]; then
    echo "직결 사용 전력(bypass): ${bypass_w} W"
  else
    echo "직결 사용 전력(bypass): 알 수 없음"
  fi
  echo "배터리 충전 전력: ${battery_charge_w} W"
  echo "배터리 사용 전력: ${battery_discharge_w} W"

  echo
  echo "[실시간 수치]"
  if [[ -n "${systemCurrentIn:-}" ]]; then
    echo "어댑터 입력 전류: $(to_fixed "$systemCurrentIn" 1000 3) A"
  else
    echo "어댑터 입력 전류: 알 수 없음"
  fi
  if [[ -n "${systemVoltageIn:-}" ]]; then
    echo "어댑터 입력 전압: $(to_fixed "$systemVoltageIn" 1000 3) V"
  else
    echo "어댑터 입력 전압: 알 수 없음"
  fi
  if [[ -n "${battery_current_ma:-}" ]]; then
    echo "배터리 전류: $(to_fixed "$battery_current_ma" 1000 3) A"
  else
    echo "배터리 전류: 알 수 없음"
  fi
  if [[ -n "${batteryVoltage:-}" ]]; then
    echo "배터리 전압: $(to_fixed "$batteryVoltage" 1000 3) V"
  else
    echo "배터리 전압: 알 수 없음"
  fi
  echo "배터리 순전력: ${battery_net_w} W"
  if [[ -n "${batteryPowerTelemetry:-}" ]]; then
    echo "배터리 전력 텔레메트리: $(to_fixed "$batteryPowerTelemetry" 1000 2) W"
  fi

  echo
  echo "[충전기 협상 프로필]"
  if [[ -n "${adapterCurrent:-}" ]]; then
    echo "최대 전류: $(to_fixed "$adapterCurrent" 1000 3) A"
  else
    echo "최대 전류: 알 수 없음"
  fi
  if [[ -n "${adapterVoltage:-}" ]]; then
    echo "최대 전압: $(to_fixed "$adapterVoltage" 1000 3) V"
  else
    echo "최대 전압: 알 수 없음"
  fi
  if [[ -n "${adapterWatts:-}" ]]; then
    echo "최대 전력: ${adapterWatts} W"
  else
    echo "최대 전력: 알 수 없음"
  fi

  sleep "$interval"
done
