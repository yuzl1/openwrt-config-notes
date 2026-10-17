# 05 DDNS-Go（腾讯云 / DNSPod）

> 离线配置阶段可以把 DDNS-Go 装好、打开配置页面；真正拿到公网 IP、更新解析要等
> [替换上线](09-cutover.md)之后。

DDNS-Go 是一个带独立网页界面的 DDNS 客户端，支持 IPv4/IPv6，配置保存在
`/etc/ddns-go/config.yaml`，升级固件时会被保留。

## 安装

```sh
opkg update
opkg install ddns-go luci-app-ddns-go luci-i18n-ddns-go-zh-cn
```

| 包 | 作用 |
| --- | --- |
| `ddns-go` | 主程序（23.05 源里是 6.8.1） |
| `luci-app-ddns-go` | LuCI 入口页（开关、监听地址、跳转到 DDNS-Go 网页） |
| `luci-i18n-ddns-go-zh-cn` | 中文界面 |

## 先卸掉旧的 ddns-scripts（如果装过）

如果之前按旧方案装过 `luci-app-ddns` / `ddns-scripts`，先停掉并卸载，避免两个
程序同时更新同一个域名：

```sh
# 停掉并关闭旧服务
/etc/init.d/ddns stop 2>/dev/null
/etc/init.d/ddns disable 2>/dev/null

# 卸载旧包
opkg remove luci-app-ddns ddns-scripts ddns-scripts-services ddns-scripts-dnspod
```

确认卸载干净：

```sh
opkg list-installed | grep -i ddns-scripts     # 应该没有输出
ps | grep '[d]dns'                              # 应该没有 ddns 进程
```

`/etc/config/ddns` 如果还在，可以留着不管，也可以手动删掉。

## 启用

### 网页方式

1. **服务 → DDNS-Go**
2. 勾选 **Enable**
3. **Listen address** 保持 `[::]:9876`（要换端口就改这里，例如 `0.0.0.0:9877`）
4. **Update interval** 默认 300 秒
5. **保存并应用**

### 命令行方式

```sh
uci set ddns-go.config.enabled='1'
uci commit ddns-go
/etc/init.d/ddns-go enable
/etc/init.d/ddns-go start
```

## 打开 DDNS-Go 自己的配置页面

在 LuCI 的 **服务 → DDNS-Go** 页面点 **Open Web Interface**，或者直接访问：

```
http://10.10.10.1:9876
```

第一次打开会让你设置这个页面的登录用户名和密码，设置好并记住。

## 配置腾讯云 / DNSPod

DDNS-Go 里有两个相关服务商，按手里的密钥类型选：

| 服务商 | 需要的凭据 | 在哪里拿 |
| --- | --- | --- |
| **Dnspod** | ID + Token | DNSPod 控制台 → 用户中心 → 密钥管理 → 创建密钥 |
| **腾讯云** | SecretId + SecretKey | 腾讯云控制台 → 访问管理 → API 密钥管理 |

### 用 DNSPod 的 ID/Token（推荐，最省事）

1. 登录 <https://console.dnspod.cn/> → 右上角头像 → **密钥管理** → **创建密钥**
2. 记下 **ID** 和 **Token**（Token 只显示一次）
3. DDNS-Go 网页 → **DNS 服务商** 选 `Dnspod` → 填 ID、Token

### 用腾讯云 API 密钥

1. 腾讯云控制台 → 访问管理 → **API 密钥管理** → 新建密钥
2. DDNS-Go → **DNS 服务商** 选 `腾讯云` → 填 SecretId、SecretKey

## 配置域名和 IP 获取方式

在 DDNS-Go 的「配置」页继续：

1. **IPv4**
   - 获取 IP 方式：**通过接口获取**
   - 网络接口：`pppoe-wan`（PPPoE 拨号后的接口）
   - 或者选「通过 API 获取」，地址填 `https://ipv4.icanhazip.com`
   - 域名：`home.example.com`，保存
2. **IPv6**（需要 AAAA 记录时再配）
   - 获取 IP 方式：通过接口获取，选 `pppoe-wan` 或 `br-lan`
   - 域名：同样填 `home.example.com`
3. 保存后回到首页，可以看到每个域名的解析状态和最近一次更新日志

## 验证

```sh
/etc/init.d/ddns-go status
netstat -lnup | grep 9876
nslookup home.example.com 8.8.8.8
nslookup -type=AAAA home.example.com 8.8.8.8
```

DDNS-Go 网页的日志里会显示更新成功或具体错误。

## 注意

- `9876` 是明文 HTTP，只在内网使用，不要把端口映射到公网；页面本身支持设置登录
  密码，务必设置。
- 配置文件 `/etc/ddns-go/config.yaml` 已列在 `/lib/upgrade/keep.d/ddns-go`，
  升级固件会保留。
- 只想要 IPv4 或只想要 IPv6 都可以，另一项留空即可。
- 宽带是运营商大内网（没有公网 IPv4）时，IPv4 记录解析出来也访问不了，用 IPv6
  或 Tailscale。
