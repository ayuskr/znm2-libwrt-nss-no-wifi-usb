#!/usr/bin/env bash
set -euo pipefail

# This script only adds package sources and overlay files.
# Do not force .config here; package symbols may not exist until feeds are installed.

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

# Important:
# Do NOT add the whole kenzok8/jell feed.
# The whole jell feed may trigger package/feeds/jell/tcping build failure.
sed -i '/kenzok8\/jell/d;/src-git jell/d' feeds.conf.default

mkdir -p package/custom

# Only copy luci-app-microsocks from kenzok8/jell.
# Do not add whole jell feed.
rm -rf package/custom/luci-app-microsocks /tmp/jell-microsocks

git clone --depth=1 --filter=blob:none --sparse https://github.com/kenzok8/jell.git /tmp/jell-microsocks
cd /tmp/jell-microsocks
git sparse-checkout set luci-app-microsocks
cd -

cp -a /tmp/jell-microsocks/luci-app-microsocks package/custom/luci-app-microsocks
rm -rf /tmp/jell-microsocks

# Fix luci-app-microsocks dependencies.
# Some versions depend on tcping. tcping fails to build on this target.
# Remove tcping dependency from luci-app-microsocks Makefile.
if [ -f package/custom/luci-app-microsocks/Makefile ]; then
  sed -i \
    -e 's/+tcping//g' \
    -e 's/+PACKAGE_luci-app-microsocks:tcping//g' \
    -e 's/ tcping//g' \
    -e 's/tcping //g' \
    package/custom/luci-app-microsocks/Makefile

  echo "==== luci-app-microsocks Makefile after tcping cleanup ===="
  grep -n "DEPENDS\|tcping" package/custom/luci-app-microsocks/Makefile || true
fi

# Lucky and GecoosAC
rm -rf package/custom/luci-app-lucky package/custom/luci-app-gecoosac
git clone --depth=1 https://github.com/gdy666/luci-app-lucky.git package/custom/luci-app-lucky
git clone --depth=1 https://github.com/laipeng668/luci-app-gecoosac.git package/custom/luci-app-gecoosac

# Aurora theme only
# Do not add luci-app-aurora-config for now; theme itself is enough and more stable.
rm -rf package/custom/luci-theme-aurora package/custom/luci-app-aurora-config
git clone --depth=1 https://github.com/eamonxg/luci-theme-aurora.git package/custom/luci-theme-aurora

# Force default LAN IP / DHCP / Chinese LuCI / Aurora theme
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

# 默认中文
uci -q set luci.main.lang='zh_cn'
uci -q set luci.languages.zh_cn='简体中文'
uci -q set luci.languages.en='English'

# 默认 Aurora 主题
uci -q set luci.main.mediaurlbase='/luci-static/aurora'

uci -q commit network
uci -q commit dhcp
uci -q commit luci

exit 0
EOC

chmod +x files/etc/uci-defaults/99-custom-defaults
