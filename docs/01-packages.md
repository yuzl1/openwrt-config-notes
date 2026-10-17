# 01 预装软件（必须在线完成）

离线配置阶段没有外网，`opkg` 装不了东西，所以这一步要**在还能上网时做完**。

## 一键安装

```sh
opkg update
opkg install \
  ddns-go luci-app-ddns-go luci-i18n-ddns-go-zh-cn \
  luci-app-wol etherwake wakeonlan \
  luci-app-commands luci-app-ttyd \
  openssh-sftp-server vim curl
```

## 每个包的作用

| 包 | 作用 |
| --- | --- |
| `ddns-go` | DDNS 客户端主程序（自带 9876 网页配置界面） |
| `luci-app-ddns-go` | LuCI 里的 DDNS-Go 入口页（开关 + 跳转） |
| `luci-i18n-ddns-go-zh-cn` | DDNS-Go 界面的中文翻译 |
| `luci-app-wol` | 网页上的网络唤醒页面 |
| `etherwake` / `wakeonlan` | 命令行发魔术包（定时任务用） |
| `luci-app-commands` | 网页里执行自定义命令（调试方便） |
| `luci-app-ttyd` | 网页终端（不想开 SSH 时用） |
| `openssh-sftp-server` | 让电脑上的 `scp` 不用加 `-O` 也能传文件 |
| `vim` | 命令行编辑配置文件（习惯精简版也可以换成 `vim-full`） |
| `curl` | 命令行调试 HTTP/HTTPS |

DDNS-Go 自带绝大多数服务商（腾讯云、DNSPod、Cloudflare、阿里云等），
不需要再装服务商脚本包。

## 验证

```sh
opkg list-installed | grep -E 'ddns|wol|etherwake|wakeonlan|ttyd|commands|sftp|vim|curl'
```

网页上应该能看到：

- **服务 → DDNS-Go**
- **网络 → Wake-on-LAN**
- **系统 → TTYD 终端**（或“终端”）

## 做完之后

- 回 **系统 → 备份/升级** 再存一份备份（带所有软件的状态）
- 之后再断开 WAN，开始离线配置

> 离线配置期间不要再卸载/安装软件。如果发现漏装，需要临时把 WAN 接回 iKuai 补装。
