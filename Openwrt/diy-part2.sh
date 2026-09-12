#!/bin/bash
#
# Modify default IP
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

# kenzok8 small-package
#sed -i '$a src-git smpackage https://github.com/kenzok8/small-package' feeds.conf.default


# 删除冲突包
#rm -rf ./feeds/packages/net/{xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,v2ray-plugin,xray-plugin,geoview,shadow-tls}
#rm -rf ./feeds/luci/applications/{luci-app-passwall,luci-app-passwall2,luci-app-openclash,luci-app-homeproxy,luci-app-lucky,luci-app-smartdns,luci-app-timecontrol,luci-app-mosdns,luci-app-nikki,luci-app-momo,luci-app-daed}

# PassWall
#git clone --depth 1 https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git package/passwall-packages

# 第三方插件
mkdir -p package/small
pushd package/small

#git clone -b master --depth 1 https://github.com/eamonxg/luci-theme-aurora.git
#git clone -b main --depth 1 https://github.com/sirpdboy/luci-app-timecontrol.git
git clone -b master --depth 1 https://github.com/immortalwrt/homeproxy.git
git clone -b main --depth 1 https://github.com/gdy666/luci-app-lucky.git

git clone -b main --depth 1 https://github.com/Openwrt-Passwall/openwrt-passwall.git ../passwall-luci
#git clone -b main --depth 1 https://github.com/Openwrt-Passwall/openwrt-passwall2.git
git clone -b v5 --depth 1 https://github.com/sbwml/luci-app-mosdns.git

git clone -b master --depth 1 https://github.com/vernesong/OpenClash.git
#git clone -b main --depth 1 https://github.com/nikkinikki-org/OpenWrt-nikki.git
#git clone -b main --depth 1 https://github.com/nikkinikki-org/OpenWrt-momo.git

popd


mkdir -p files/etc/uci-defaults

cat > files/etc/uci-defaults/zz-enable-wifi <<'EOF'
#!/bin/sh
. /lib/functions.sh

# 无线配置不存在则自动生成
[ -s /etc/config/wireless ] || wifi config

# 开启所有 Wi-Fi
if [ -s /etc/config/wireless ]; then
	config_load wireless
	enable_wifi() {
		local cfg="$1"
		uci -q set "wireless.${cfg}.disabled=0"
	}
	config_foreach enable_wifi wifi-device
	config_foreach enable_wifi wifi-iface
	uci -q commit wireless
fi

exit 0
EOF

chmod +x files/etc/uci-defaults/zz-enable-wifi
