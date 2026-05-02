#!/usr/bin/env bash
set -euo pipefail

# Add PassWall official feeds before feeds update.
if ! grep -q 'openwrt-passwall-packages' feeds.conf.default; then
  sed -i '1isrc-git passwall_packages https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main' feeds.conf.default
fi
if ! grep -q 'openwrt-passwall.git' feeds.conf.default; then
  sed -i '1isrc-git passwall_luci https://github.com/Openwrt-Passwall/openwrt-passwall.git;main' feeds.conf.default
fi

# Add Lucky and GecoosAC as local packages.
mkdir -p package/custom
rm -rf package/custom/lucky package/custom/luci-app-gecoosac

git clone --depth=1 https://github.com/gdy666/luci-app-lucky.git package/custom/lucky
git clone --depth=1 https://github.com/laipeng668/luci-app-gecoosac.git package/custom/luci-app-gecoosac

# Force default LAN IP and Chinese LuCI language through files overlay.
mkdir -p files/etc/uci-defaults
cat > files/etc/uci-defaults/99-custom-defaults <<'EOC'
#!/bin/sh
uci set network.lan.ipaddr='192.168.10.1'
uci set luci.main.lang='zh_cn'
uci commit network
uci commit luci
exit 0
EOC
chmod +x files/etc/uci-defaults/99-custom-defaults

# Strongly remove WiFi/USB selections after feeds are available and before defconfig.
cat >> .config <<'EOC'

# ---- Force no WiFi ----
# CONFIG_PACKAGE_ipq-wifi-zn_m2 is not set
# CONFIG_PACKAGE_ath11k-firmware-ipq6018 is not set
# CONFIG_PACKAGE_kmod-ath is not set
# CONFIG_PACKAGE_kmod-ath11k is not set
# CONFIG_PACKAGE_kmod-ath11k-ahb is not set
# CONFIG_PACKAGE_kmod-ath11k-pci is not set
# CONFIG_PACKAGE_kmod-cfg80211 is not set
# CONFIG_PACKAGE_kmod-mac80211 is not set
# CONFIG_PACKAGE_wireless-regdb is not set
# CONFIG_PACKAGE_wifi-scripts is not set
# CONFIG_PACKAGE_iw is not set
# CONFIG_PACKAGE_iwinfo is not set
# CONFIG_PACKAGE_libiwinfo is not set
# CONFIG_PACKAGE_libiwinfo-data is not set
# CONFIG_PACKAGE_wpad is not set
# CONFIG_PACKAGE_wpad-basic is not set
# CONFIG_PACKAGE_wpad-basic-mbedtls is not set
# CONFIG_PACKAGE_wpad-basic-openssl is not set
# CONFIG_PACKAGE_wpad-mbedtls is not set
# CONFIG_PACKAGE_wpad-openssl is not set
# CONFIG_PACKAGE_wpad-wolfssl is not set
# CONFIG_PACKAGE_hostapd is not set
# CONFIG_PACKAGE_hostapd-common is not set
# CONFIG_PACKAGE_hostapd-utils is not set
# CONFIG_PACKAGE_wpa-cli is not set
# CONFIG_PACKAGE_wpa-supplicant is not set

# ---- Force no USB ----
# CONFIG_PACKAGE_kmod-usb-core is not set
# CONFIG_PACKAGE_kmod-usb2 is not set
# CONFIG_PACKAGE_kmod-usb3 is not set
# CONFIG_PACKAGE_kmod-usb-dwc3 is not set
# CONFIG_PACKAGE_kmod-usb-dwc3-qcom is not set
# CONFIG_PACKAGE_kmod-usb-ehci is not set
# CONFIG_PACKAGE_kmod-usb-ohci is not set
# CONFIG_PACKAGE_kmod-usb-storage is not set
# CONFIG_PACKAGE_kmod-usb-storage-uas is not set
# CONFIG_PACKAGE_kmod-usb-net is not set
# CONFIG_PACKAGE_kmod-usb-net-cdc-ether is not set
# CONFIG_PACKAGE_kmod-usb-net-rndis is not set
# CONFIG_PACKAGE_usbutils is not set
# CONFIG_PACKAGE_block-mount is not set
# CONFIG_PACKAGE_automount is not set
EOC
