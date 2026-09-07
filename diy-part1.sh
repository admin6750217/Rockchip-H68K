#!/bin/bash
#===============================================
# Description: DIY script
# File name: diy-script.sh
# Lisence: MIT
# Author: P3TERX
# Blog: https://p3terx.com
#===============================================

# =========================================================
# 无线网络：开机自动启用
# =========================================================

mkdir -p files/etc/uci-defaults

cat > files/etc/uci-defaults/99-enable-wifi <<'EOF'
#!/bin/sh

# 如果无线配置不存在，则生成无线配置
[ -f /etc/config/wireless ] || wifi config

# 启用所有 Wi-Fi 射频设备
uci -q show wireless | grep '=wifi-device' | cut -d. -f2 | while read radio; do
    uci -q set wireless.$radio.disabled='0'
done

# 启用所有 Wi-Fi 接口
uci -q show wireless | grep '=wifi-iface' | cut -d. -f2 | while read iface; do
    uci -q set wireless.$iface.disabled='0'
done

uci commit wireless

exit 0
EOF

chmod +x files/etc/uci-defaults/99-enable-wifi
