#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 VIKINGYFY

if [ -n "${GITHUB_WORKSPACE:-}" ] && [ -d "$GITHUB_WORKSPACE/wrt/package" ]; then
	PKG_PATH="$GITHUB_WORKSPACE/wrt/package"
else
	PKG_PATH="$(pwd)"
fi

# 修改实际启用的Argon主题配置
ARGON_CONFIG="$PKG_PATH/luci-theme-argon/luci-app-argon-config/root/etc/config/argon"
if [ -f "$ARGON_CONFIG" ]; then
	sed -i "s/primary '.*'/primary '#31a1a1'/; s/'0.2'/'0.5'/; s/'none'/'bing'/; s/'600'/'normal'/" "$ARGON_CONFIG"
	echo "theme-argon has been fixed!"
fi

# 修复unetd在新GCC下的array-bounds报错
UNETD_HOST_FILE="$(find "$PKG_PATH" -maxdepth 5 -type f -wholename '*/network/services/unetd/host.c' -print -quit 2>/dev/null)"
if [ -f "$UNETD_HOST_FILE" ]; then
	perl -0pi -e 's/host->node\.key = strcpy\(name_buf, name\);/memcpy(name_buf, name, strlen(name) + 1);\n\thost->node.key = name_buf;/' "$UNETD_HOST_FILE"
	echo "unetd has been fixed!"
fi
