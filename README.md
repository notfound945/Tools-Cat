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
当前支持的朋友分发入口只有一个：
```bash
sh ./release.sh
```

当前脚本会直接做本地 `Release` 构建，对 app 补一个稳定的 ad-hoc 签名后，再打包出一个给朋友分发的 DMG，不要求 Apple Developer Program、Developer ID 或 notarization。最终产物为：
- `dist/Tools-Cat.dmg`

运行过程中还会保留：
- `build/DerivedData/Build/Products/Release/Tools Cat.app`

发布后可运行：
```bash
bash scripts/release/verify-distribution-closure.sh
```

这个验证会静态检查 release/docs 合同、挂载 `dist/Tools-Cat.dmg` 确认其中包含 `Tools Cat.app` 和 `/Applications` 快捷方式，并重跑聚焦的 WOL / 常亮回归测试。

完整的运行说明、限制和朋友侧打开方式见：
- `docs/release/signing-readiness.md`

注意：
- 这个 DMG 内的 app 会保留 bundle id 绑定的 ad-hoc 签名，但不做 Apple notarization。
- 朋友第一次打开时，可能需要对 App 执行“右键打开”。
- 如果仍被 Gatekeeper 拦截，可以移除隔离属性：
```bash
xattr -dr com.apple.quarantine "/Applications/Tools Cat.app"
```
- 保留 ad-hoc 签名的原因之一，是让通知这类系统权限能稳定识别 `Tools Cat` 的应用身份，而不是退化成未绑定 bundle 的临时可执行产物。
- 上面的脚本验证不等于 fresh-machine / 真实朋友侧 Gatekeeper 验证；那部分仍需要手工烟雾确认。

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
