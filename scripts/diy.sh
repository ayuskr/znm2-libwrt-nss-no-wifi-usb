#!/usr/bin/env bash
set -euo pipefail

echo "==== Fix GitHub clone rules ===="
git config --global --unset-all url.https://github.com/.insteadOf || true
git config --global --unset-all url.git@github.com:.insteadOf || true

echo "==== Add PassWall official feeds ===="
sed -i '/openwrt-passwall-packages/d;/openwrt-passwall.git/d;/passwall_packages/d;/passwall_luci/d;/src-git passwall /d' feeds.conf.default
sed -i '1isrc-git passwall_luci https://github.com/Openwrt-Passwall/openwrt-passwall.git;main' feeds.conf.default
sed -i '1isrc-git passwall_packages https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main' feeds.conf.default

echo "==== Add MosDNS feed ===="
sed -i '/sbwml\/luci-app-mosdns/d;/mosdns_luci/d' feeds.conf.default
sed -i '1isrc-git mosdns_luci https://github.com/sbwml/luci-app-mosdns.git;v5' feeds.conf.default

echo "==== Clean custom package dir ===="
mkdir -p package/custom

rm -rf package/custom/luci-app-lucky
rm -rf package/custom/luci-app-gecoosac
rm -rf package/custom/luci-theme-aurora
rm -rf package/custom/luci-app-aurora-config
rm -rf package/custom/luci-app-microsocks
rm -rf package/custom/luci-app-microsocks-lite
rm -rf package/custom/jell

echo "==== Clone Lucky ===="
git clone --depth=1 https://github.com/gdy666/luci-app-lucky.git package/custom/luci-app-lucky

echo "==== Clone GecoosAC ===="
git clone --depth=1 https://github.com/laipeng668/luci-app-gecoosac.git package/custom/luci-app-gecoosac

echo "==== Clone Aurora theme ===="
git clone --depth=1 https://github.com/eamonxg/luci-theme-aurora.git package/custom/luci-theme-aurora

echo "==== Add luci-app-microsocks from jell only ===="
git clone --depth=1 https://github.com/kenzok8/jell.git package/custom/jell

if [ -d package/custom/jell/luci-app-microsocks ]; then
  cp -r package/custom/jell/luci-app-microsocks package/custom/luci-app-microsocks
else
  echo "ERROR: luci-app-microsocks not found in kenzok8/jell"
  exit 1
fi

rm -rf package/custom/jell

echo "==== Remove possible duplicate microsocks LuCI apps ===="
find feeds package -path "*/luci-app-microsocks-lite" -type d -prune -exec rm -rf {} + 2>/dev/null || true

echo "==== Remove WiFi packages from device default packages ===="
grep -RIl "ipq-wifi-zn_m2\|kmod-ath11k\|ath11k-firmware\|wpad\|wifi-scripts\|kmod-mac80211\|kmod-cfg80211" target/linux/qualcommax 2>/dev/null | while read -r file; do
  sed -i \
    -e 's/[[:space:]]ipq-wifi-zn_m2//g' \
    -e 's/[[:space:]]ath11k-firmware-ipq6018//g' \
    -e 's/[[:space:]]ath11k-firmware-ipq8074//g' \
    -e 's/[[:space:]]kmod-ath//g' \
    -e 's/[[:space:]]kmod-ath11k//g' \
    -e 's/[[:space:]]kmod-ath11k-ahb//g' \
    -e 's/[[:space:]]kmod-ath11k-pci//g' \
    -e 's/[[:space:]]kmod-cfg80211//g' \
    -e 's/[[:space:]]kmod-mac80211//g' \
    -e 's/[[:space:]]wireless-regdb//g' \
    -e 's/[[:space:]]wifi-scripts//g' \
    -e 's/[[:space:]]iwinfo//g' \
    -e 's/[[:space:]]iw//g' \
    -e 's/[[:space:]]wpad-basic-mbedtls//g' \
    -e 's/[[:space:]]wpad-openssl//g' \
    -e 's/[[:space:]]wpad-full-openssl//g' \
    -e 's/[[:space:]]hostapd-common//g' \
    "$file"
done

echo "==== Remove USB packages from device default packages ===="
grep -RIl "kmod-usb\|usbutils\|automount\|block-mount\|luci-app-diskman" target/linux/qualcommax 2>/dev/null | while read -r file; do
  sed -i \
    -e 's/[[:space:]]kmod-usb-core//g' \
    -e 's/[[:space:]]kmod-usb2//g' \
    -e 's/[[:space:]]kmod-usb3//g' \
    -e 's/[[:space:]]kmod-usb-dwc3//g' \
    -e 's/[[:space:]]kmod-usb-dwc3-qcom//g' \
    -e 's/[[:space:]]kmod-usb-ehci//g' \
    -e 's/[[:space:]]kmod-usb-ohci//g' \
    -e 's/[[:space:]]kmod-usb-storage//g' \
    -e 's/[[:space:]]kmod-usb-storage-uas//g' \
    -e 's/[[:space:]]kmod-usb-net//g' \
    -e 's/[[:space:]]kmod-usb-net-cdc-ether//g' \
    -e 's/[[:space:]]kmod-usb-net-rndis//g' \
    -e 's/[[:space:]]usbutils//g' \
    -e 's/[[:space:]]block-mount//g' \
    -e 's/[[:space:]]automount//g' \
    -e 's/[[:space:]]luci-app-diskman//g' \
    -e 's/[[:space:]]luci-app-hd-idle//g' \
    "$file"
done

echo "==== Create default settings ===="
mkdir -p files/etc/uci-defaults

cat > files/etc/uci-defaults/99-custom-defaults <<'EOC'
#!/bin/sh

# LAN IP
uci -q set network.lan.ipaddr='192.168.10.1'
uci -q set network.lan.netmask='255.255.255.0'

# DHCP
uci -q set dhcp.lan=dhcp
uci -q set dhcp.lan.interface='lan'
uci -q set dhcp.lan.start='100'
uci -q set dhcp.lan.limit='150'
uci -q set dhcp.lan.leasetime='12h'
uci -q set dhcp.lan.ignore='0'

# Chinese
uci -q set luci.main.lang='zh_cn'
uci -q set luci.languages.zh_cn='简体中文'
uci -q set luci.languages.en='English'

# Aurora theme
uci -q set luci.main.mediaurlbase='/luci-static/aurora'

# Dropbear SSH
uci -q delete dropbear.@dropbear[0]
uci -q add dropbear dropbear
uci -q set dropbear.@dropbear[0].PasswordAuth='on'
uci -q set dropbear.@dropbear[0].RootPasswordAuth='on'
uci -q set dropbear.@dropbear[0].Port='22'
uci -q set dropbear.@dropbear[0].Interface='lan'

uci -q commit network
uci -q commit dhcp
uci -q commit luci
uci -q commit dropbear

/etc/init.d/dropbear enable
/etc/init.d/dropbear restart

rm -rf /tmp/luci-indexcache
rm -rf /tmp/luci-modulecache

exit 0
EOC

chmod +x files/etc/uci-defaults/99-custom-defaults

echo "==== DIY done ===="
