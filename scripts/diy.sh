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
# Do NOT copy luci-app-microsocks from jell.
# jell version may depend on tcping, and tcping fails to build on this target.
sed -i '/kenzok8\/jell/d;/src-git jell/d' feeds.conf.default

mkdir -p package/custom

# -------------------------------------------------------------------
# Create a minimal local luci-app-microsocks package.
# This version does NOT depend on tcping.
# -------------------------------------------------------------------
rm -rf package/custom/luci-app-microsocks
mkdir -p package/custom/luci-app-microsocks/luasrc/controller
mkdir -p package/custom/luci-app-microsocks/luasrc/model/cbi
mkdir -p package/custom/luci-app-microsocks/root/etc/config
mkdir -p package/custom/luci-app-microsocks/root/etc/init.d

cat > package/custom/luci-app-microsocks/Makefile <<'EOF'
include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-microsocks
PKG_VERSION:=1.0
PKG_RELEASE:=1

LUCI_TITLE:=LuCI support for microsocks
LUCI_DEPENDS:=+microsocks +luci-base +luci-compat
LUCI_PKGARCH:=all

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
EOF

cat > package/custom/luci-app-microsocks/luasrc/controller/microsocks.lua <<'EOF'
module("luci.controller.microsocks", package.seeall)

function index()
    if not nixio.fs.access("/etc/config/microsocks") then
        return
    end

    entry({"admin", "services", "microsocks"}, cbi("microsocks"), _("MicroSocks"), 60).dependent = true
end
EOF

cat > package/custom/luci-app-microsocks/luasrc/model/cbi/microsocks.lua <<'EOF'
local fs = require "nixio.fs"

m = Map("microsocks", translate("MicroSocks"), translate("A tiny SOCKS5 server."))

s = m:section(TypedSection, "microsocks", translate("Settings"))
s.anonymous = true
s.addremove = false

o = s:option(Flag, "enabled", translate("Enable"))
o.rmempty = false
o.default = "0"

o = s:option(Value, "bindaddr", translate("Listen address"))
o.datatype = "ipaddr"
o.placeholder = "0.0.0.0"
o.default = "0.0.0.0"

o = s:option(Value, "port", translate("Listen port"))
o.datatype = "port"
o.placeholder = "1080"
o.default = "1080"

o = s:option(Value, "user", translate("Username"))
o.rmempty = true

o = s:option(Value, "password", translate("Password"))
o.password = true
o.rmempty = true

return m
EOF

cat > package/custom/luci-app-microsocks/root/etc/config/microsocks <<'EOF'
config microsocks 'config'
	option enabled '0'
	option bindaddr '0.0.0.0'
	option port '1080'
	option user ''
	option password ''
EOF

cat > package/custom/luci-app-microsocks/root/etc/init.d/microsocks <<'EOF'
#!/bin/sh /etc/rc.common

START=99
USE_PROCD=1

start_service() {
	config_load microsocks

	local enabled bindaddr port user password
	config_get_bool enabled config enabled 0
	[ "$enabled" -eq 1 ] || return 0

	config_get bindaddr config bindaddr "0.0.0.0"
	config_get port config port "1080"
	config_get user config user ""
	config_get password config password ""

	procd_open_instance
	procd_set_param command /usr/bin/microsocks -i "$bindaddr" -p "$port"

	if [ -n "$user" ]; then
		procd_append_param command -u "$user"
	fi

	if [ -n "$password" ]; then
		procd_append_param command -P "$password"
	fi

	procd_set_param respawn
	procd_close_instance
}

reload_service() {
	stop
	start
}
EOF

chmod +x package/custom/luci-app-microsocks/root/etc/init.d/microsocks

echo "==== local luci-app-microsocks created ===="
grep -n "LUCI_DEPENDS" package/custom/luci-app-microsocks/Makefile || true
grep -R "tcping" package/custom/luci-app-microsocks || true

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
