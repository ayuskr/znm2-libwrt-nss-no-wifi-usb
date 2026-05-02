#!/usr/bin/env bash
set -euo pipefail

fail=0

echo '==== 检查 ZN M2 目标 ===='
grep -E '^CONFIG_TARGET_qualcommax_ipq60xx_DEVICE_zn_m2=y$' .config || {
  echo 'ERROR: 当前不是 zn_m2 设备目标，请检查 CONFIG_TARGET_qualcommax_ipq60xx_DEVICE_zn_m2'
  fail=1
}

echo '==== 检查 WiFi 驱动/服务/无线内核栈是否被启用 ===='
# libiwinfo/libiwinfo-data 是 LuCI 可能依赖的信息库，不等于启用 WiFi。
# 真正会带 WiFi 功能的是下面这些：固件、ath/mac80211/cfg80211、wifi-scripts、iw/iwinfo、wpad/hostapd/wpa。
WIFI_PATTERNS='CONFIG_PACKAGE_(ipq-wifi|ath11k|kmod-ath($|11k)|kmod-ath11k|kmod-cfg80211|kmod-mac80211|wireless-regdb|wifi-scripts|iw$|iw-full|iwinfo|wpad|hostapd|wpa-cli|wpa-supplicant|luci-app-wifi)'
if grep -E "^${WIFI_PATTERNS}.*=y" .config; then
  echo 'ERROR: WiFi packages still enabled'
  fail=1
else
  echo 'OK: WiFi drivers/services disabled'
fi

if grep -E '^CONFIG_PACKAGE_libiwinfo(-data)?=y' .config; then
  echo 'WARN: libiwinfo/libiwinfo-data exists because LuCI may depend on it; it is not a WiFi driver/service.'
fi

echo '==== 检查 USB 核心组件是否被启用 ===='
USB_PATTERNS='CONFIG_PACKAGE_(kmod-usb|usbutils|block-mount|automount|luci-app-diskman|luci-app-hd-idle)'
if grep -E "^${USB_PATTERNS}.*=y" .config; then
  echo 'ERROR: USB packages still enabled'
  fail=1
else
  echo 'OK: USB packages disabled'
fi

echo '==== 检查四个插件是否启用 ===='
for p in luci-app-passwall luci-app-mosdns luci-app-lucky luci-app-gecoosac; do
  symbol="CONFIG_PACKAGE_${p}=y"
  if grep -q "^${symbol}$" .config; then
    echo "OK: ${p} enabled"
  else
    echo "ERROR: ${p} not enabled"
    fail=1
  fi
done

if [ "$fail" -ne 0 ]; then
  echo '配置检查失败，请查看上面的 ERROR。'
  echo '你可以在上方日志搜索 WARNING: skipping unavailable package，确认对应插件 feed 是否拉取成功。'
  exit 1
fi
