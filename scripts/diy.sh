#!/usr/bin/env bash
set -euo pipefail

# This script only adds package sources and overlay files.
# Do not force .config here; package symbols may not exist until feeds are installed.

# PassWall official feeds
sed -i '/openwrt-passwall-packages/d;/openwrt-passwall.git/d;/passwall_packages/d;/passwall_luci/d' feeds.conf.default
sed -i '1isrc-git passwall_packages https://github.com/OpenWrt-Actions/openwrt-passwall-packages.git;main' feeds.conf.default
sed -i '1isrc-git passwall_luci https://github.com/OpenWrt-Actions/openwrt-passwall.git;main' feeds.conf.default

# MosDNS feed. LiBwrt sometimes does not expose luci-app-mosdns after target switch,
# so add a known standalone feed.
sed -i '/sbwml\/luci-app-mosdns/d;/mosdns_luci/d' feeds.conf.default
sed -i '1isrc-git mosdns_luci https://github.com/sbwml/luci-app-mosdns.git;v5' feeds.conf.default

# Lucky and GecoosAC as local packages.
mkdir -p package/custom
rm -rf package/custom/luci-app-lucky package/custom/luci-app-gecoosac
git clone --depth=1 https://github.com/gdy666/luci-app-lucky.git package/custom/luci-app-lucky
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
