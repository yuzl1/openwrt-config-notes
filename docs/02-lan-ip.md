# 01 修改 LAN 为 10.10.10.1

这一步在**离线配置阶段**做（软件已装好、WAN 已断开）。PPPoE / IPv6 / DDNS
都和 LAN 网段无关，可以先配，但改 LAN 一定要在“按 MAC 固定 IP”
（[06](06-dhcp-static.md)）之前，因为绑定地址属于 LAN 网段。

改完路由器会换 IP，当前页面会断开。

## 网页操作

1. **网络 → 接口 → LAN → 编辑**
2. **常规设置**：
   - 协议：静态地址
   - IPv4 地址：`10.10.10.1`
   - 子网掩码：`255.255.255.0`
   - （可选）IPv4 网关、广播留空
3. 切到 **DHCP 服务器 → 常规设置**：

| 选项 | 值 |
| --- | --- |
| 忽略此接口 | 不勾 |
| 起始地址 | `10.10.10.100` |
| 限制地址数 | `150` |
| 租约时间 | `12h` |
| 强制 | 勾上（可选） |
| DHCP 选项 | `6,10.10.10.1`（把 DNS 指向自己） |

4. 点 **保存 → 保存并应用**

## 改完之后怎么连回来

- 电脑改成静态 IP：`10.10.10.2 / 255.255.255.0`，网关 `10.10.10.1`
- 或者断开重连 WiFi/网线，让电脑重新 DHCP（拿到 `10.10.10.100` 之后）
- 浏览器打开 `http://10.10.10.1`

> 旧的 `192.168.1.1` 之后就不存在了，别再用它排查问题。

## 命令行等价写法

```sh
uci set network.lan.ipaddr='10.10.10.1'
uci set network.lan.netmask='255.255.255.0'
uci set dhcp.lan.start='100'
uci set dhcp.lan.limit='150'
uci set dhcp.lan.leasetime='12h'
uci -q delete dhcp.lan.dhcp_option
uci add_list dhcp.lan.dhcp_option='6,10.10.10.1'
uci commit network
uci commit dhcp
/etc/init.d/network restart
```

## 验证

```sh
ip -4 addr show br-lan          # 应该看到 10.10.10.1/24
uci get dhcp.lan.start && uci get dhcp.lan.limit   # 100 / 150
```

## 注意

- 如果原来有静态 IP 的设备（NAS、打印机、摄像头），要么手动改成 `10.10.10.x`，
  要么在 [06](06-dhcp-static.md) 里按 MAC 重新绑定。
- 改 LAN 之后先别急着做别的，确认能正常上网/进管理页再继续。
