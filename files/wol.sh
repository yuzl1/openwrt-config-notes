#!/bin/sh
#
# 发送 Wake-on-LAN 魔术包
#
#   wol.sh AA:BB:CC:DD:EE:FF
#
MAC="${1:-AA:BB:CC:DD:EE:FF}"

logger -t wol "wake ${MAC}"

if command -v etherwake >/dev/null 2>&1; then
	etherwake -b "${MAC}"
elif command -v wakeonlan >/dev/null 2>&1; then
	wakeonlan "${MAC}"
else
	logger -t wol "neither etherwake nor wakeonlan is installed"
	exit 1
fi
