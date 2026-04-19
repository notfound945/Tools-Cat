import SwiftUI

enum InputMode: String {
    case custom = "手动填写 MAC"
    case preset = "保存设备列表"
}

struct WOLView: View {
    @ObservedObject var session: WOLSessionModel
    @ObservedObject var deviceLibrary: SavedDeviceLibraryStore

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("唤醒局域网设备 (WOL)")
                .font(.system(size: 17, weight: .semibold))

            HStack(spacing: 20) {
                RadioButton(selectedMode: $session.inputMode, mode: .custom, label: "手动填写 MAC")
                RadioButton(selectedMode: $session.inputMode, mode: .preset, label: "保存设备列表")
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityIdentifier("wol-mode-group")

            if session.inputMode == .custom {
                VStack(alignment: .leading, spacing: 8) {
                    Text("MAC 地址")
                        .font(.system(size: 12, weight: .semibold))

                    TextField(
                        "请输入 MAC 地址",
                        text: Binding(
                            get: { session.customMac },
                            set: { session.updateCustomMac($0) }
                        )
                    )
                    .textFieldStyle(.roundedBorder)
                    .accessibilityIdentifier("wol-custom-mac-field")
                    .onSubmit { session.sendCurrentSelection() }
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Picker("选择设备", selection: $session.selectedSavedDeviceID) {
                        Text("请选择设备...")
                            .tag(nil as UUID?)
                        ForEach(deviceLibrary.devices) { device in
                            (Text(device.name) + Text("  \(device.macAddress)").font(.caption).foregroundColor(.secondary))
                                .tag(device.id as UUID?)
                        }
                    }
                    .pickerStyle(.menu)
                    .accessibilityIdentifier("wol-saved-device-picker")
                }
            }

            if let statusText = visibleStatusText {
                Text(statusText)
                    .font(.system(size: 12))
                    .foregroundColor(statusTextColor)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityIdentifier("wol-status-block")
            }

            HStack(spacing: 16) {
                Spacer()

                Button(action: {
                    NotificationCenter.default.post(name: .WOLWindowRequestClose, object: nil)
                }) {
                    Text("取消")
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .accessibilityIdentifier("wol-cancel-button")

                Button(action: session.sendCurrentSelection) {
                    if session.isSending {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Text("发送唤醒包")
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(session.isSending || !session.canSend)
                .accessibilityIdentifier("wol-send-button")
            }
            .accessibilityIdentifier("wol-action-row")
        }
        .padding(.top, 24)
        .padding(.horizontal, 16)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    private var visibleStatusText: String? {
        switch session.sendState {
        case .idle:
            if session.inputMode == .custom {
                return session.validation.userMessage
            }
            return nil
        case .sending(let macAddress):
            _ = macAddress
            return WakeSendMessage.sending.text
        case .success(let message), .failure(let message):
            return message
        }
    }

    private var statusTextColor: Color {
        switch session.sendState {
        case .idle:
            return session.inputMode == .custom && session.validation.userMessage != nil ? .orange : .secondary
        case .sending:
            return .secondary
        case .success:
            return .green
        case .failure:
            return .orange
        }
    }
}

struct RadioButton: View {
    @Binding var selectedMode: InputMode
    let mode: InputMode
    let label: String

    var body: some View {
        Button(action: {
            selectedMode = mode
        }) {
            HStack(spacing: 8) {
                Image(systemName: selectedMode == mode ? "largecircle.fill.circle" : "circle")
                    .foregroundColor(selectedMode == mode ? .accentColor : .secondary)
                Text(label)
                    .lineLimit(1)
                    .foregroundColor(.primary)
            }
            .fixedSize(horizontal: true, vertical: false)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
