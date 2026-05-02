# ZN M2 LiBwrt NSS 无 WiFi / 无 USB 固件云编译仓库

目标：基于 LiBwrt `openwrt-6.x` 的 `main-nss` 分支，为 **兆能 M2 / ZN M2 / IPQ6000 / qualcommax-ipq60xx** 生成主路由固件。

内置插件：

- PassWall
- MosDNS
- Lucky
- Gecoos AC

定制项：

- 禁用 WiFi：移除 `ipq-wifi-zn_m2`、`kmod-ath11k*`、`ath11k-firmware*`、`mac80211`、`wpad/hostapd`、`wifi-scripts`、`iw/iwinfo` 等。
- 禁用 USB：移除 `kmod-usb*`、`usbutils`、`block-mount`、`automount`、`luci-app-diskman` 等。
- 保留主路由和 NSS 加速相关包。
- 默认 LAN IP：`192.168.10.1`，可在 `files/etc/uci-defaults/99-custom-defaults` 修改。
- 默认中文 LuCI。
- 自动上传 Artifact，自动创建 Release。

## 使用方法

1. 新建一个 GitHub 仓库。
2. 上传本仓库全部文件。
3. 进入 GitHub 仓库：`Actions` → 启用 Workflow。
4. 手动运行：`Build ZN M2 LiBwrt NSS NoWiFi NoUSB`。
5. 编译完成后在 `Actions Artifacts` 或 `Releases` 下载固件。

## 重要说明

如果 Release 步骤报 403：

进入仓库 `Settings` → `Actions` → `General` → `Workflow permissions`：

- 选择 `Read and write permissions`
- 勾选 `Allow GitHub Actions to create and approve pull requests`

然后重新运行工作流。

## 文件说明

```text
.github/workflows/build-znm2.yml   # GitHub Actions 主流程
configs/znm2.config                # ZN M2 固件配置
scripts/diy.sh                     # 插件源、默认设置、去 WiFi/USB 强制修正
scripts/check-no-wifi-usb.sh       # 编译前严格检查
files/etc/uci-defaults/99-custom-defaults # 默认 LAN IP、中文语言
```
