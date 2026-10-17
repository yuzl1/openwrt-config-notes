# 04 DDNS（动态域名）

> 离线配置阶段可以把条目建好，但真正解析验证要等[替换上线](09-cutover.md)、
> 拿到公网地址之后。

## 安装

```sh
opkg update
opkg install luci-app-ddns ddns-scripts ddns-scripts-services
```

再按服务商装一个脚本，例如 Cloudflare：

```sh
opkg install ddns-scripts-cloudflare
```

（阿里云、DuckDNS、No-IP 等有对应的 `ddns-scripts-*` 包，`opkg list | grep ddns-scripts` 可以查。）

## 网页操作

1. **服务 → 动态 DNS → 添加新条目**

| 选项 | 值 |
| --- | --- |
| 查询主机名 | `ipv4.icanhazip.com`（或 `checkip.dyndns.com`） |
| 域名 | 你的域名，如 `home.example.com` |
| 用户名 | 服务商账号 / API Token（按服务商要求） |
| 密码 | 对应密钥 |
| 接口 | `wan`（PPPoE 的话就是 pppoe-wan 所在的 wan） |
| 服务商 | 例如 `cloudflare.com-v4` |
| 检查间隔 | 默认 10 分钟 |

2. **保存并应用**，然后点条目右侧的 **重新加载**
3. 看日志：**状态 → 系统日志**，或 `logread | grep ddns`

## IPv6 的 DDNS

同样添加一个条目，但：

- “查询主机名”换成 IPv6 的检测地址（如 `ipv6.icanhazip.com`）
- 服务商选带 `-v6` 的版本（如 `cloudflare.com-v6`）
- 接口选 `wan6`

## 验证

```sh
nslookup home.example.com 8.8.8.8
```

返回的应该是你现在的公网 IP。IP 变了之后，等一个检查周期再看。

## 注意

- Cloudflare 用 API Token 时，权限只需要对应 zone 的 `DNS:Edit`。
- 如果家里是 **大内网**（运营商 NAT，没有公网 IPv4），DDNS 解析出来也没法从外网访问，
  这种情况要么找运营商要公网 IP，要么用 Tailscale / ZeroTier 之类。
- 有公网 IPv6 时，可以直接做 `AAAA` 记录的 DDNS，配合防火墙放行需要的端口。
