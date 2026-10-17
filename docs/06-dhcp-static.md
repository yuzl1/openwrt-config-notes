# 03 按 MAC 固定 IP

> 请**先完成 [02 修改 LAN 网段](02-lan-ip.md)**，再做这里面的固定绑定。
> 固定地址属于 LAN 网段，先在 `192.168.1.x` 里绑定，改完 LAN 就全部失效了。

## 网页操作

### 方法一：从当前租约一键绑定（推荐）

1. **网络 → DHCP/DNS → 已分配的租约**
2. 找到要固定的设备，点右边的 **加入静态分配**
3. 把 IP 改成 `10.10.10.10` ~ `10.10.10.99` 之间的地址（和 DHCP 池错开）
4. 给个主机名（如 `nas`、`printer`）方便识别
5. **保存并应用**

### 方法二：手动添加

**网络 → DHCP/DNS → 静态地址 → 添加**：

| 字段 | 说明 |
| --- | --- |
| 主机名 | 例如 `nas` |
| MAC 地址 | 目标设备的 MAC（`AA:BB:CC:DD:EE:FF`） |
| IPv4 地址 | 例如 `10.10.10.20` |
| 租约时间 | 留空用默认 |

## 命令行等价写法

```sh
uci add dhcp host
uci set dhcp.@host[-1].name='nas'
uci set dhcp.@host[-1].mac='AA:BB:CC:DD:EE:FF'
uci set dhcp.@host[-1].ip='10.10.10.20'
uci commit dhcp
/etc/init.d/dnsmasq restart
```

## 验证

```sh
cat /tmp/dhcp.leases | grep -i 10.10.10.20
```

设备重新连网（或 `dhclient -r && dhclient`）后应该拿到绑定地址。

## 注意

- IP 建议固定用 `10.10.10.2` ~ `10.10.10.99`，把 `100` 以上留给动态租约。
- 手机、笔记本如果开了“随机 MAC”，绑定会失效，需要在 WiFi 设置里关掉随机 MAC。
- 固定 IP 的设备如果换了网卡/主板，MAC 变了要记得回来改。
