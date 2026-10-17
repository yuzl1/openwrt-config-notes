# 05 网络唤醒（WoL）

## 前提

目标机器（NAS / 台式机）要支持并开启 WoL：

- BIOS/UEFI 里打开 `Wake on LAN` / `Power On by PCIe`
- 系统网卡驱动里允许“魔术包唤醒”
- 关机后网卡仍需待机供电（主板关机后 USB/网卡不断电）

## 安装

```sh
opkg update
opkg install luci-app-wol etherwake
```

安装完 LuCI 会出现 **网络 → Wake-on-LAN**。

## 手动唤醒

1. **网络 → Wake-on-LAN**
2. 填目标机的 MAC（`AA:BB:CC:DD:EE:FF`）
3. 接口选 `br-lan`
4. 点 **唤醒**

## 定时唤醒

### 1. 放一个脚本

把仓库里的 [`files/wol.sh`](../files/wol.sh) 传到路由器：

```sh
scp -O files/wol.sh root@10.10.10.1:/root/wol.sh
ssh root@10.10.10.1 'chmod +x /root/wol.sh'
```

脚本内容（可以自己改 MAC）：

```sh
#!/bin/sh
MAC="${1:-AA:BB:CC:DD:EE:FF}"
logger -t wol "wake $MAC"
etherwake -b "$MAC" || wakeonlan "$MAC"
```

### 2. 加计划任务

**系统 → 计划任务（cron）**，加一行，例如工作日早上 8 点唤醒 NAS：

```cron
0 8 * * 1-5 /root/wol.sh AA:BB:CC:DD:EE:FF
```

保存后 cron 会自动生效（也可以 `/etc/init.d/cron restart`）。

### 3. 验证

```sh
logread | grep wol
crontab -l
```

到点后目标机应该自动开机；没开机的话先在页面上手动唤醒一次，确认是网络/配置问题
还是机器本身不支持。

## 注意

- WoL 的魔术包只能在同一广播域（LAN）内生效；跨网段需要在目标网段做 directed
  broadcast 或 relay。
- 如果 NAS 关机后网卡断电，WoL 不会生效，检查主板/电源设置。
- 有些设备需要先“允许来自关机状态的网络唤醒”，Windows 在网卡属性 → 电源管理里。
