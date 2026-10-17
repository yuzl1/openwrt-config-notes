# OpenWrt / ImmortalWrt 配置笔记（红米 AX3000 / RA81）

记录这台红米 AX3000（RA81）刷 ImmortalWrt 23.05.3 之后，用来替换原来
iKuai 路由器需要做的配置，以及每一步的验证方法。

## 设备现状

| 项目 | 值 |
| --- | --- |
| 设备 | Redmi AX3000（RA81），IPQ5000，arm 32 位 |
| 固件 | ImmortalWrt 23.05.3（`ipq50xx/arm`，`arm_cortex-a7_neon-vfpv4`） |
| 管理地址 | `http://10.10.10.1`（改之前是 192.168.1.1） |
| LAN 网段 | `10.10.10.0/24`，网关 `10.10.10.1` |
| DHCP 池 | `10.10.10.100` – `10.10.10.249` |
| WAN | PPPoE 拨号 |

## 目标

1. DDNS
2. 按 MAC 固定 IP
3. 网络唤醒（可定时）
4. PPPoE 拨号
5. 开启 IPv6
6. LAN 改为 `10.10.10.1`，DHCP 同网段

## 建议顺序

1. 先做一次配置备份（见 [07](docs/07-backup-restore.md)）
2. 改 LAN 为 `10.10.10.1`（会断线，必须先做）→ [01](docs/01-lan-ip.md)
3. 配 PPPoE 拨号 → [02](docs/02-pppoe.md)
4. 开 IPv6 → [06](docs/06-ipv6.md)
5. 配静态地址绑定 → [03](docs/03-dhcp-static.md)
6. 配 DDNS → [04](docs/04-ddns.md)
7. 配网络唤醒 → [05](docs/05-wake-on-lan.md)

## 文档索引

| 文档 | 内容 |
| --- | --- |
| [01-lan-ip.md](docs/01-lan-ip.md) | 改 LAN IP 为 10.10.10.1 + DHCP 池 |
| [02-pppoe.md](docs/02-pppoe.md) | PPPoE 拨号、VLAN、MTU |
| [03-dhcp-static.md](docs/03-dhcp-static.md) | 按 MAC 固定 IP |
| [04-ddns.md](docs/04-ddns.md) | DDNS（Cloudflare 等） |
| [05-wake-on-lan.md](docs/05-wake-on-lan.md) | 网络唤醒 + 定时任务 |
| [06-ipv6.md](docs/06-ipv6.md) | IPv6（DHCPv6 / PD / RA） |
| [07-backup-restore.md](docs/07-backup-restore.md) | 备份与恢复 |

## 通用说明

- 所有操作都可以在 LuCI 网页完成，文档里同时给了命令行等价写法（SSH 用）。
- 每改完一处都要点 **保存并应用**，否则不会生效。
- 每一步都给了验证命令，验证通过再进下一步，避免一次改太多不好排查。
- 建议每完成一步就做一次备份（见 07）。
