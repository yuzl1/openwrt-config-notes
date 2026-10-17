# 07 备份与恢复

## 网页备份

1. **系统 → 备份/升级**
2. **生成备份** → 下载 `.tar.gz` 到电脑
3. 文件名里带日期，方便回滚

建议时机：

- 刷机完成、确认能上网之后
- 改完 LAN IP / PPPoE / IPv6 之后各一次
- 每次加 DDNS、WoL、静态绑定之后

## 命令行备份

```sh
sysupgrade -b /tmp/backup-$(date +%F).tar.gz
scp -O root@10.10.10.1:/tmp/backup-*.tar.gz ./
```

## 恢复

**系统 → 备份/升级 → 恢复备份** → 选择 `.tar.gz` → 恢复。

命令行：

```sh
sysupgrade -r /tmp/backup-2026-10-17.tar.gz
```

## 注意

- 备份只包含 `/etc`（配置），不包含已安装的软件包本身；恢复后可能需要重新
  `opkg install` 之前额外装的包（如 ddns、wol）。
- 改 LAN IP 之后恢复旧备份，IP 也会跟着变回去。
- 保留至少两份：刷机后一份、稳定运行一周后一份。
