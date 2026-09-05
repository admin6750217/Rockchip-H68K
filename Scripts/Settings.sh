#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 VIKINGYFY

#移除luci-app-attendedsysupgrade
sed -i "/attendedsysupgrade/d" $(find ./feeds/luci/collections/ -type f -name "Makefile")
#修改immortalwrt.lan关联IP
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $(find ./feeds/luci/modules/luci-mod-system/ -type f -name "flash.js")

CFG_FILE="./package/base-files/files/bin/config_generate"
#修改默认IP地址
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $CFG_FILE
#修改默认主机名
sed -i "s/hostname='.*'/hostname='$WRT_NAME'/g" $CFG_FILE

#配置文件修改
echo "CONFIG_PACKAGE_luci=y" >> ./.config
echo "CONFIG_LUCI_LANG_zh_Hans=y" >> ./.config
if [[ "${WRT_CONFIG^^}" == "ROCKCHIP" ]]; then
	# H68K不编译源码设备定义继承的网卡和GPU显示驱动
	ROCKCHIP_IMAGE="./target/linux/rockchip/image/armv8.mk"
	if [ -f "$ROCKCHIP_IMAGE" ] && grep -q "define Device/hinlink_opc-h68k" "$ROCKCHIP_IMAGE"; then
		perl -0pi -e 's/(define Device\/hinlink_opc-h68k\n\$\(call Device\/hinlink_common\)\n  DEVICE_MODEL := OPC-H68K\n  SOC := rk3568\n)/$1  DEVICE_PACKAGES += -kmod-r8125-rss -kmod-drm-rockchip\n/' "$ROCKCHIP_IMAGE"
	fi

	# H68K刷机后自动启用无线并立即拉起无线接口
	H68K_DEFAULTS="./package/base-files/files/etc/uci-defaults/99-h68k-defaults"
	mkdir -p "$(dirname "$H68K_DEFAULTS")"
	cat > "$H68K_DEFAULTS" <<'EOF'
#!/bin/sh

[ -s /etc/config/wireless ] || wifi config

for device in $(uci -q show wireless | sed -n 's/^\(wireless\.[^.]*\)=wifi-device$/\1/p'); do
	uci -q set "$device.disabled=0"
done

for iface in $(uci -q show wireless | sed -n 's/^\(wireless\.[^.]*\)=wifi-iface$/\1/p'); do
	uci -q set "$iface.disabled=0"
	uci -q set "$iface.mode=ap"
	uci -q set "$iface.network=lan"
	uci -q set "$iface.encryption=psk2"
	uci -q set "$iface.ssid=__H68K_SSID__"
	uci -q set "$iface.key=__H68K_WORD__"
done

uci -q commit wireless
wifi up >/dev/null 2>&1 || true
exit 0
EOF
	sed -i "s/__H68K_SSID__/$WRT_SSID/g; s/__H68K_WORD__/$WRT_WORD/g" "$H68K_DEFAULTS"
	chmod 0755 "$H68K_DEFAULTS"
fi

#允许手动追加插件配置
if [ -n "$WRT_PACKAGE" ]; then
	echo -e "$WRT_PACKAGE" >> ./.config
fi
