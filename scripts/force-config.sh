#!/usr/bin/env bash
set -euo pipefail

unset_config() {
  local sym="$1"
  sed -i "/^${sym}=y$/d;/^${sym}=m$/d;/^# ${sym} is not set$/d" .config
  echo "# ${sym} is not set" >> .config
}

set_config() {
  local sym="$1"
  sed -i "/^${sym}=y$/d;/^${sym}=m$/d;/^# ${sym} is not set$/d" .config
  echo "${sym}=y" >> .config
}

# ZN M2 target
set_config CONFIG_TARGET_qualcommax
set_config CONFIG_TARGET_qualcommax_ipq60xx
set_config CONFIG_TARGET_qualcommax_ipq60xx_DEVICE_zn_m2

# LAN / DHCP / base network
for sym in \
  CONFIG_PACKAGE_netifd \
  CONFIG_PACKAGE_ubus \
  CONFIG_PACKAGE_uci \
  CONFIG_PACKAGE_dnsmasq-full \
  CONFIG_PACKAGE_odhcp6c \
  CONFIG_PACKAGE_odhcpd-ipv6only \
  CONFIG_PACKAGE_firewall4 \
  CONFIG_PACKAGE_nftables \
  CONFIG_PACKAGE_kmod-nft-offload \
  CONFIG_PACKAGE_ppp \
  CONFIG_PACKAGE_ppp-mod-pppoe \
  CONFIG_PACKAGE_kmod-dsa \
  CONFIG_PACKAGE_kmod-dsa-qca8k \
  CONFIG_PACKAGE_kmod-phy-qca83xx \
  CONFIG_PACKAGE_kmod-phy-aquantia \
  CONFIG_PACKAGE_kmod-gpio-button-hotplug; do
  set_config "$sym"
done

# NSS acceleration
for sym in \
  CONFIG_PACKAGE_kmod-qca-nss-dp \
  CONFIG_PACKAGE_kmod-qca-nss-drv \
  CONFIG_PACKAGE_kmod-qca-nss-drv-bridge-mgr \
  CONFIG_PACKAGE_kmod-qca-nss-drv-igs \
  CONFIG_PACKAGE_kmod-qca-nss-drv-lag-mgr \
  CONFIG_PACKAGE_kmod-qca-nss-drv-vlan-mgr \
  CONFIG_PACKAGE_kmod-qca-nss-drv-pppoe \
  CONFIG_PACKAGE_kmod-nss-ifb; do
  set_config "$sym"
done

# Disable unused NSS modules
for sym in \
  CONFIG_PACKAGE_kmod-qca-nss-drv-pptp \
  CONFIG_PACKAGE_kmod-qca-nss-drv-l2tpv2 \
  CONFIG_PACKAGE_kmod-qca-nss-drv-gre \
  CONFIG_PACKAGE_kmod-qca-nss-crypto; do
  unset_config "$sym"
done

# LuCI / theme
for sym in \
  CONFIG_PACKAGE_luci \
  CONFIG_PACKAGE_luci-ssl \
  CONFIG_PACKAGE_luci-base \
  CONFIG_PACKAGE_luci-compat \
  CONFIG_PACKAGE_luci-lib-ipkg \
  CONFIG_PACKAGE_luci-app-firewall \
  CONFIG_PACKAGE_luci-theme-bootstrap \
  CONFIG_PACKAGE_luci-theme-aurora; do
  set_config "$sym"
done

# Chinese language
set_config CONFIG_LUCI_LANG_zh_Hans

for sym in \
  CONFIG_PACKAGE_luci-i18n-base-zh-cn \
  CONFIG_PACKAGE_luci-i18n-firewall-zh-cn \
  CONFIG_PACKAGE_luci-i18n-passwall-zh-cn \
  CONFIG_PACKAGE_luci-i18n-mosdns-zh-cn; do
  set_config "$sym"
done

unset_config CONFIG_PACKAGE_luci-app-aurora-config

# Plugins
for sym in \
  CONFIG_PACKAGE_luci-app-passwall \
  CONFIG_PACKAGE_luci-i18n-passwall-zh-cn \
  CONFIG_PACKAGE_luci-app-mosdns \
  CONFIG_PACKAGE_luci-i18n-mosdns-zh-cn \
  CONFIG_PACKAGE_mosdns \
  CONFIG_PACKAGE_v2dat \
  CONFIG_PACKAGE_luci-app-lucky \
  CONFIG_PACKAGE_lucky \
  CONFIG_PACKAGE_luci-app-gecoosac \
  CONFIG_PACKAGE_microsocks; do
  set_config "$sym"
done

# Disable microsocks LuCI app
unset_config CONFIG_PACKAGE_luci-app-microsocks
unset_config CONFIG_PACKAGE_luci-app-microsocks-lite

# Minimal PassWall cores
for sym in \
  CONFIG_PACKAGE_chinadns-ng \
  CONFIG_PACKAGE_dns2socks \
  CONFIG_PACKAGE_ipt2socks \
  CONFIG_PACKAGE_v2ray-geodata \
  CONFIG_PACKAGE_xray-core; do
  set_config "$sym"
done

# Disable heavy PassWall cores
for sym in \
  CONFIG_PACKAGE_haproxy \
  CONFIG_PACKAGE_naiveproxy \
  CONFIG_PACKAGE_shadowsocks-rust-sslocal \
  CONFIG_PACKAGE_shadowsocks-rust-ssserver \
  CONFIG_PACKAGE_shadowsocksr-libev-ssr-local \
  CONFIG_PACKAGE_simple-obfs \
  CONFIG_PACKAGE_sing-box \
  CONFIG_PACKAGE_trojan-plus \
  CONFIG_PACKAGE_tuic-client \
  CONFIG_PACKAGE_v2ray-core \
  CONFIG_PACKAGE_xray-plugin; do
  unset_config "$sym"
done

# Keep firmware smaller
for sym in \
  CONFIG_PACKAGE_htop \
  CONFIG_PACKAGE_nano \
  CONFIG_PACKAGE_wget-ssl \
  CONFIG_PACKAGE_ca-certificates \
  CONFIG_PACKAGE_openssh-sftp-server; do
  unset_config "$sym"
done

# No WiFi
for sym in \
  CONFIG_PACKAGE_ipq-wifi-zn_m2 \
  CONFIG_PACKAGE_ath11k-firmware-ipq6018 \
  CONFIG_PACKAGE_kmod-ath \
  CONFIG_PACKAGE_kmod-ath11k \
  CONFIG_PACKAGE_kmod-ath11k-ahb \
  CONFIG_PACKAGE_kmod-ath11k-pci \
  CONFIG_PACKAGE_kmod-cfg80211 \
  CONFIG_PACKAGE_kmod-mac80211 \
  CONFIG_PACKAGE_wireless-regdb \
  CONFIG_PACKAGE_wifi-scripts \
  CONFIG_PACKAGE_iw \
  CONFIG_PACKAGE_iw-full \
  CONFIG_PACKAGE_iwinfo \
  CONFIG_PACKAGE_wpad \
  CONFIG_PACKAGE_wpad-basic \
  CONFIG_PACKAGE_wpad-basic-mbedtls \
  CONFIG_PACKAGE_wpad-basic-openssl \
  CONFIG_PACKAGE_wpad-mbedtls \
  CONFIG_PACKAGE_wpad-openssl \
  CONFIG_PACKAGE_wpad-wolfssl \
  CONFIG_PACKAGE_hostapd \
  CONFIG_PACKAGE_hostapd-common \
  CONFIG_PACKAGE_hostapd-utils \
  CONFIG_PACKAGE_wpa-cli \
  CONFIG_PACKAGE_wpa-supplicant \
  CONFIG_PACKAGE_luci-app-wifi; do
  unset_config "$sym"
done

# No USB
for sym in \
  CONFIG_PACKAGE_kmod-usb-core \
  CONFIG_PACKAGE_kmod-usb2 \
  CONFIG_PACKAGE_kmod-usb3 \
  CONFIG_PACKAGE_kmod-usb-dwc3 \
  CONFIG_PACKAGE_kmod-usb-dwc3-qcom \
  CONFIG_PACKAGE_kmod-usb-ehci \
  CONFIG_PACKAGE_kmod-usb-ohci \
  CONFIG_PACKAGE_kmod-usb-storage \
  CONFIG_PACKAGE_kmod-usb-storage-uas \
  CONFIG_PACKAGE_kmod-usb-net \
  CONFIG_PACKAGE_kmod-usb-net-cdc-ether \
  CONFIG_PACKAGE_kmod-usb-net-rndis \
  CONFIG_PACKAGE_usbutils \
  CONFIG_PACKAGE_block-mount \
  CONFIG_PACKAGE_automount \
  CONFIG_PACKAGE_luci-app-diskman \
  CONFIG_PACKAGE_luci-app-hd-idle; do
  unset_config "$sym"
done

make defconfig

# Force Chinese again after defconfig
set_config CONFIG_LUCI_LANG_zh_Hans
set_config CONFIG_PACKAGE_luci-i18n-base-zh-cn
set_config CONFIG_PACKAGE_luci-i18n-firewall-zh-cn
set_config CONFIG_PACKAGE_luci-i18n-passwall-zh-cn
set_config CONFIG_PACKAGE_luci-i18n-mosdns-zh-cn

# Disable microsocks LuCI app again
unset_config CONFIG_PACKAGE_luci-app-microsocks
unset_config CONFIG_PACKAGE_luci-app-microsocks-lite

make defconfig

echo "==== Check target ===="
grep -E '^CONFIG_TARGET_qualcommax|^CONFIG_TARGET_qualcommax_ipq60xx|^CONFIG_TARGET_qualcommax_ipq60xx_DEVICE_zn_m2' .config || true

echo "==== Check LAN / DHCP ===="
grep -E '^CONFIG_PACKAGE_(dnsmasq-full|netifd|odhcp6c|odhcpd-ipv6only|kmod-dsa|kmod-dsa-qca8k|kmod-phy-qca83xx|kmod-gpio-button-hotplug)=y' .config || true

echo "==== Check Chinese / Aurora / microsocks ===="
grep -E '^CONFIG_LUCI_LANG_zh_Hans=y|^CONFIG_PACKAGE_luci-i18n-base-zh-cn=y|^CONFIG_PACKAGE_luci-i18n-firewall-zh-cn=y|^CONFIG_PACKAGE_luci-i18n-passwall-zh-cn=y|^CONFIG_PACKAGE_luci-i18n-mosdns-zh-cn=y|^CONFIG_PACKAGE_luci-theme-aurora=y|^CONFIG_PACKAGE_microsocks=y' .config || true

echo "==== Strict check Chinese language support ===="
if ! grep -q '^CONFIG_LUCI_LANG_zh_Hans=y' .config && ! grep -q '^CONFIG_PACKAGE_luci-i18n-base-zh-cn=y' .config; then
  echo "ERROR: Chinese language support is missing"
  exit 1
fi

echo "==== Check no microsocks LuCI app ===="
if grep -E '^CONFIG_PACKAGE_luci-app-microsocks=y|^CONFIG_PACKAGE_luci-app-microsocks-lite=y' .config; then
  echo "ERROR: luci-app-microsocks / luci-app-microsocks-lite still enabled"
  exit 1
fi

echo "==== Check no jell feed ===="
if grep -R "kenzok8/jell" feeds.conf.default package feeds 2>/dev/null; then
  echo "ERROR: jell feed still exists"
  exit 1
fi

echo "==== Check no WiFi ===="
if grep -E '^CONFIG_PACKAGE_(ipq-wifi|ath11k|kmod-ath11k|kmod-mac80211|kmod-cfg80211|wifi-scripts|wpad|hostapd|iw)=y' .config; then
  echo "ERROR: WiFi packages still enabled"
  exit 1
fi

echo "==== Check no USB ===="
if grep -E '^CONFIG_PACKAGE_(kmod-usb|usbutils|automount|block-mount|luci-app-diskman)=y' .config; then
  echo "ERROR: USB packages still enabled"
  exit 1
fi
