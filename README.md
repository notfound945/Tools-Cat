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

## 构建 Release（二选一）
方法 A：脚本一键构建（推荐）
```bash
sh ./release.sh
```

方法 B：命令行构建
```bash
xcodebuild -project "Tools Cat.xcodeproj" -scheme "Tools Cat" -configuration Release -derivedDataPath build clean build
```

## 打包 DMG（不公证）
- 先构建出 Release .app，再使用脚本打包到 dist/
```bash
# 若已通过脚本或 Xcode 生成了 Release .app：
chmod +x ./build_dmg.sh
./build_dmg.sh "./build/Build/Products/Release/Tools Cat.app"
# 可选：自定义文件名/卷名/输出目录
# OUT_DIR="$(pwd)/dist" ./build_dmg.sh "./build/Build/Products/Release/Tools Cat.app" "MyApp.dmg" "My App"
```

生成产物：
- dist/Tools-Cat.dmg

说明：未做公证，用户首次安装需在“系统设置 → 隐私与安全”允许，或右键-打开。

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
