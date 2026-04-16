# Tools Cat

一个纯菜单栏的小工具：
- 保持屏幕常亮（仅阻止显示器休眠）
- 局域网唤醒（WOL）：选择预设设备或输入自定义 MAC 发送魔术包

## 功能
- 菜单栏图标：
  - 开启常亮：bolt.fill
  - 关闭常亮：bolt.slash
- 菜单项：
  - 保持屏幕常亮（开/关）
  - 唤醒局域网设备 (WOL)…（打开窗口，支持预设与自定义 MAC）
  - 退出

## 开发与运行
1) 使用 Xcode 打开工程，选择 Scheme“Tools Cat”
2) 直接 Run 即可（应用以菜单栏图标运行，无主窗口）

## Release
维护者发布入口只有一个：
```bash
sh ./release.sh
```

运行前需要提供以下环境变量：
```bash
export RELEASE_TEAM_ID=Y2YJ48R9GL
export RELEASE_SIGNING_IDENTITY='Developer ID Application: <Common Name> (Y2YJ48R9GL)'
export RELEASE_NOTARY_PROFILE=TOOLS_CAT_NOTARY
```

当前脚本会执行签名预检、归档、导出已签名应用、打包并签名 DMG、公证提交、stapling 以及本地评估，最终产物为：
- `dist/Tools-Cat.dmg`

运行过程中还会保留：
- `build/archive/Tools Cat.xcarchive`
- `dist/export/Tools Cat.app`
- `build/notary/Tools-Cat-notary-submit.plist`
- `build/notary/Tools-Cat-notary-log.json`（仅公证被拒时生成）

完整的证书准备、`notarytool` profile 初始化、预检失败说明与当前 runbook 见：
- `docs/release/signing-readiness.md`

Phase 17 负责把发布链路推进到已签名、已公证、已 stapled 的 `Tools-Cat.dmg`。Phase 18 再补齐可重复的 fresh-machine 安装验证与更完整的发布回归闭环。

## 更名后的可选清理
- 只建议在你确认 `Tools Cat` 首次启动成功、历史保存设备也已经迁移后，再做旧标识清理。
- 旧的 defaults 域可手动删除：
```bash
defaults delete cn.notfound945.Mac-OS-Swiss-Knife
```
- 可选 historical cleanup：如果本机还留着旧产物，也可以手动删除历史 `Mac OS Swiss Knife.app` 或 `Mac-OS-Swiss-Knife.dmg` 副本。

## 权限与沙盒
- 已启用 App Sandbox，开启了出站网络权限（com.apple.security.network.client），用于发送 UDP 广播（WOL）。
- 首次运行如提示网络访问，请选择允许。

## WOL 使用提示
- 目标设备需在 BIOS/系统中开启 WOL；机器需断电待机而非完全断电。
- 在某些网络/防火墙/VPN 环境，广播可能被拦截；脚本会尝试对各网口推导的广播地址发送并绑定接口（IP_BOUND_IF）。
- Xcode 控制台会打印发送的接口名（如 en0）与目标广播地址，便于排查。
