#!/usr/bin/env bash
set -euo pipefail

# This script only adds package sources and overlay files.
# Do not force .config here; package symbols may not exist until feeds are installed.

# GitHub Actions sometimes keeps extra URL rewrite rules from user configs; make cloning deterministic.
git config --global --unset-all url.https://github.com/.insteadOf || true
git config --global --unset-all url.git@github.com:.insteadOf || true

# PassWall official public feeds.
# Do NOT use OpenWrt-Actions/openwrt-passwall or OpenWrt-Actions/openwrt-passwall-packages:
# those URLs are not the current public PassWall feeds and may trigger GitHub auth prompts.
sed -i '/openwrt-passwall-packages/d;/openwrt-passwall.git/d;/passwall_packages/d;/passwall_luci/d;/src-git passwall /d' feeds.conf.default
sed -i '1isrc-git passwall https://github.com/Openwrt-Passwall/openwrt-passwall.git;main' feeds.conf.default
sed -i '1isrc-git passwall_packages https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main' feeds.conf.default

# MosDNS feed. LiBwrt sometimes does not expose luci-app-mosdns after target switch,
# so add a known standalone feed.
sed -i '/sbwml\/luci-app-mosdns/d;/mosdns_luci/d' feeds.conf.default
sed -i '1isrc-git mosdns_luci https://github.com/sbwml/luci-app-mosdns.git;v5' feeds.conf.default

# Lucky and GecoosAC as local packages.
mkdir -p package/custom
rm -rf package/custom/luci-app-lucky package/custom/luci-app-gecoosac
git clone --depth=1 https://github.com/gdy666/luci-app-lucky.git package/custom/luci-app-lucky
git clone --depth=1 https://github.com/laipeng668/luci-app-gecoosac.git package/custom/luci-app-gecoosac

# Force default LAN IP / DHCP / Chinese LuCI
mkdir -p files/etc/uci-defaults

cat > files/etc/uci-defaults/99-custom-defaults <<'EOC'
#!/bin/sh

# 默认 LAN 地址
uci -q set network.lan.ipaddr='192.168.10.1'
uci -q set network.lan.netmask='255.255.255.0'

# 确保 LAN DHCP 开启
uci -q set dhcp.lan=dhcp
uci -q set dhcp.lan.interface='lan'
uci -q set dhcp.lan.start='100'
uci -q set dhcp.lan.limit='150'
uci -q set dhcp.lan.leasetime='12h'
uci -q set dhcp.lan.ignore='0'

# 中文 LuCI
uci -q set luci.main.lang='zh_cn'

uci -q commit network
uci -q commit dhcp
uci -q commit luci

exit 0
EOC

chmod +x files/etc/uci-defaults/99-custom-defaults
