#!/usr/bin/env bash
set -euo pipefail

# Fix GitHub clone rules
git config --global --unset-all url.https://github.com/.insteadOf || true
git config --global --unset-all url.git@github.com:.insteadOf || true

# PassWall official feeds
sed -i '/openwrt-passwall-packages/d;/openwrt-passwall.git/d;/passwall_packages/d;/passwall_luci/d;/src-git passwall /d' feeds.conf.default
sed -i '1isrc-git passwall_luci https://github.com/Openwrt-Passwall/openwrt-passwall.git;main' feeds.conf.default
sed -i '1isrc-git passwall_packages https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main' feeds.conf.default

# MosDNS feed
sed -i '/sbwml\/luci-app-mosdns/d;/mosdns_luci/d' feeds.conf.default
sed -i '1isrc-git mosdns_luci https://github.com/sbwml/luci-app-mosdns.git;v5' feeds.conf.default

# Do NOT add whole jell feed
sed -i '/kenzok8\/jell/d;/src-git jell/d' feeds.conf.default

mkdir -p package/custom

# Remove microsocks LuCI app
rm -rf package/custom/luci-app-microsocks
rm -rf package/custom/luci-app-microsocks-lite
find package feeds -maxdepth 5 -type d -name "luci-app-microsocks" -exec rm -rf {} + 2>/dev/null || true
find package feeds -maxdepth 5 -type d -name "luci-app-microsocks-lite" -exec rm -rf {} + 2>/dev/null || true

# Lucky and GecoosAC
rm -rf package/custom/luci-app-lucky package/custom/luci-app-gecoosac
git clone --depth=1 https://github.com/gdy666/luci-app-lucky.git package/custom/luci-app-lucky
git clone --depth=1 https://github.com/laipeng668/luci-app-gecoosac.git package/custom/luci-app-gecoosac

# Aurora theme
rm -rf package/custom/luci-theme-aurora package/custom/luci-app-aurora-config
git clone --depth=1 https://github.com/eamonxg/luci-theme-aurora.git package/custom/luci-theme-aurora

# Default LAN IP / DHCP / Chinese / Aurora
mkdir -p files/etc/uci-defaults

cat > files/etc/uci-defaults/99-custom-defaults <<'EOC'
#!/bin/sh

uci -q set network.lan.ipaddr='192.168.10.1'
uci -q set network.lan.netmask='255.255.255.0'

uci -q set dhcp.lan=dhcp
uci -q set dhcp.lan.interface='lan'
uci -q set dhcp.lan.start='100'
uci -q set dhcp.lan.limit='150'
uci -q set dhcp.lan.leasetime='12h'
uci -q set dhcp.lan.ignore='0'

# 默认中文
uci -q set luci.main.lang='zh_cn'
uci -q set luci.languages.zh_cn='简体中文'
uci -q set luci.languages.en='English'

# 默认 Aurora 主题
uci -q set luci.main.mediaurlbase='/luci-static/aurora'

uci -q commit network
uci -q commit dhcp
uci -q commit luci

rm -rf /tmp/luci-indexcache
rm -rf /tmp/luci-modulecache

exit 0
EOC

chmod +x files/etc/uci-defaults/99-custom-defaults
