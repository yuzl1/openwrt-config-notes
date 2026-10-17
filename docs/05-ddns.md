# 05 DDNS（腾讯云 DNSPod）

> 离线配置阶段可以把条目建好，但真正解析验证要等[替换上线](09-cutover.md)、
> 拿到公网地址之后。

## 安装

```sh
opkg update
opkg install luci-app-ddns ddns-scripts ddns-scripts-services \
  ddns-scripts-dnspod curl
```

说明：

- `ddns-scripts-dnspod` 对应 **dnspod.cn**（DNSPod 国内版，也就是腾讯云 DNSPod）
- 如果你用的是国际版 dnspod.com，换成 `ddns-scripts-dnspod-com`

## 先申请 API 密钥

1. 打开 DNSPod 控制台：<https://console.dnspod.cn/>
2. 右上角头像 → **密钥管理**（用户中心 → 密钥管理）
3. 点 **创建密钥**，会得到两样东西：

   - **ID**：一串数字
   - **Token**：一长串字符，**只显示一次**，立刻保存

4. 这个 ID + Token 就是下面 LuCI 里的“用户名 + 密码”，**不是你的登录密码**

## 在 LuCI 里配置（IPv4 / A 记录）

**服务 → 动态 DNS → 添加新条目**

| 选项 | 值 |
| --- | --- |
| 查询主机名 | `ipv4.icanhazip.com`（或 `checkip.dyndns.com`） |
| 域名 | 你的域名，如 `home.example.com` |
| 用户名 | DNSPod 的 **ID**（数字） |
| 密码 | DNSPod 的 **Token** |
| 接口 | `wan` |
| 服务商 | `dnspod.cn` |
| 检查间隔 | `10` 分钟 |
| 强制更新 | 关闭 |
| 使用 HTTPS | 勾上 |

保存并应用，然后点条目右侧的 **重新加载**。

## IPv6（AAAA 记录）

DNSPod 的脚本会根据 IP 版本自动写 `A` 或 `AAAA`，所以再建一个条目即可：

| 选项 | 值 |
| --- | --- |
| 查询主机名 | `ipv6.icanhazip.com` |
| 域名 | 同一个域名 |
| 用户名 / 密码 | 同上 |
| 接口 | `wan6` |
| 服务商 | `dnspod.cn` |
| IP 版本 | **IPv6** |

## 验证

```sh
logread | grep ddns
nslookup home.example.com 8.8.8.8
```

日志里应出现 `dnspod.cn` 的更新成功记录；DNS 查询返回你当前的公网地址。

IPv6 可以这样查：

```sh
nslookup -type=AAAA home.example.com 8.8.8.8
```

## 注意

- 域名的 NS 必须已经指向 DNSPod，否则 API 找不到记录。
- DNSPod 免费版的 TTL 一般最小 600 秒，更新后要等 TTL 过期才能看到变化。
- 如果宽带是运营商大内网（没有公网 IPv4），A 记录解析出来也访问不了；这种情况
  用 IPv6 的 AAAA 记录，或者直接用 Tailscale。
- 密钥泄露就等于域名被别人控制，建议在 DNSPod 里只给这个密钥最小权限，必要时随时重置。
