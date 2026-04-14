import AppKit
import SwiftUI

struct DeviceLibraryView: View {
    @ObservedObject var session: DeviceLibrarySessionModel

    var body: some View {
        Group {
            switch session.screen {
            case .list:
                listContent
            case .form(let mode):
                formContent(mode: mode)
            }
        }
        .padding(24)
        .frame(minWidth: 520, minHeight: 420, alignment: .topLeading)
        .alert(
            session.pendingDeleteDevice.map {
                DeviceLibraryManagementPresentation.deleteConfirmationMessage(deviceName: $0.name)
            } ?? "",
            isPresented: deleteAlertIsPresented
        ) {
            Button("取消", role: .cancel) {
                session.cancelDelete()
            }
            Button("删除设备", role: .destructive) {
                session.confirmDelete()
            }
        }
    }

    private var listContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 8) {
                Text(DeviceLibraryManagementPresentation.listTitle)
                    .font(.system(size: 17, weight: .semibold))

                Spacer()

                if !session.devices.isEmpty {
                    Button(DeviceLibraryManagementPresentation.reorderButtonTitle(isReordering: session.isReordering)) {
                        session.isReordering.toggle()
                    }
                    .buttonStyle(.bordered)
                }

                Button("添加设备") {
                    session.beginAdd()
                }
                .buttonStyle(.borderedProminent)
            }
            .accessibilityIdentifier("device-library-top-actions")

            if session.devices.isEmpty {
                emptyState
            } else {
                populatedListContent
            }
        }
    }

    private var populatedListContent: some View {
        Group {
            if session.isReordering {
                List {
                    ForEach(session.devices) { device in
                        DeviceRow(
                            device: device,
                            isReordering: true,
                            onEdit: { session.beginEdit(deviceID: device.id) },
                            onDelete: { session.requestDelete(deviceID: device.id) }
                        )
                    }
                    .onMove(perform: session.moveDevices)
                }
                .listStyle(.inset)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(session.devices.enumerated()), id: \.element.id) { entry in
                            let index = entry.offset
                            let device = entry.element
                            DeviceRow(
                                device: device,
                                isReordering: false,
                                onEdit: { session.beginEdit(deviceID: device.id) },
                                onDelete: { session.requestDelete(deviceID: device.id) }
                            )

                            if index < session.devices.count - 1 {
                                Divider()
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .accessibilityElement(children: .contain)
            }
        }
        .accessibilityIdentifier("device-library-list")
        .overlay(alignment: .topLeading) {
            AccessibilityMarker(
                identifier: "device-library-list",
                label: "已保存设备列表"
            )
            .frame(width: 1, height: 1)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "desktopcomputer")
                .font(.system(size: 32))
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                Text(DeviceLibraryManagementPresentation.emptyStateHeading)
                    .font(.system(size: 17, weight: .semibold))

                Text(DeviceLibraryManagementPresentation.emptyStateBody)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: 280)
            }

            Button("添加设备") {
                session.beginAdd()
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("device-library-empty-add-button")

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("device-library-empty-state")
        .overlay(alignment: .topLeading) {
            AccessibilityMarker(
                identifier: "device-library-empty-state",
                label: "还没有已保存设备"
            )
            .frame(width: 1, height: 1)
        }
    }

    private func formContent(mode: DeviceLibraryFormMode) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(DeviceLibraryManagementPresentation.formTitle(mode: mode))
                .font(.system(size: 17, weight: .semibold))

            fieldGroup(title: "名称") {
                TextField("请输入设备名称", text: $session.draftName)
                    .textFieldStyle(.roundedBorder)
            } message: {
                session.nameValidationMessage
            }

            fieldGroup(title: "MAC 地址") {
                TextField("AA:BB:CC:DD:EE:FF", text: $session.draftMACAddress)
                    .textFieldStyle(.roundedBorder)
            } message: {
                session.macAddressValidationMessage
            }

            fieldGroup(title: "备注（可选）") {
                TextField("可填写位置、用途或说明", text: $session.draftNote, axis: .vertical)
                    .lineLimit(3, reservesSpace: true)
                    .textFieldStyle(.roundedBorder)
            } message: {
                nil
            }

            if let saveErrorMessage = session.saveErrorMessage {
                Text(saveErrorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Spacer()

            HStack(spacing: 8) {
                Spacer()

                Button("取消") {
                    session.cancelForm()
                }
                .buttonStyle(.bordered)

                Button(DeviceLibraryManagementPresentation.saveButtonTitle) {
                    session.saveDraft()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!session.canSaveDraft)
            }
            .accessibilityIdentifier("device-library-form-actions")
        }
    }

    private func fieldGroup<Control: View>(
        title: String,
        @ViewBuilder control: () -> Control,
        message: () -> String?
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)

            control()

            if let message = message() {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
    }

    private var deleteAlertIsPresented: Binding<Bool> {
        Binding(
            get: { session.pendingDeleteDevice != nil },
            set: { isPresented in
                if !isPresented {
                    session.cancelDelete()
                }
            }
        )
    }
}

private struct DeviceRow: View {
    let device: SavedDevice
    let isReordering: Bool
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(device.name)
                    .font(.system(size: 13, weight: .semibold))
                    .accessibilityIdentifier("device-name-\(device.id.uuidString)")

                Text(device.macAddress)
                    .font(.system(size: 13, design: .monospaced))
                    .accessibilityIdentifier("device-mac-\(device.id.uuidString)")

                if !device.note.isEmpty {
                    Text(device.note)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .accessibilityIdentifier("device-note-\(device.id.uuidString)")
                }
            }

            Spacer()

            if isReordering {
                Image(systemName: "line.3.horizontal")
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            } else {
                HStack(spacing: 8) {
                    Button("编辑", action: onEdit)
                        .buttonStyle(.borderless)

                    Button("删除", role: .destructive, action: onDelete)
                        .buttonStyle(.borderless)
                }
            }
        }
        .padding(.vertical, 16)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("device-row-\(device.id.uuidString)")
        .overlay(alignment: .topLeading) {
            AccessibilityMarker(
                identifier: "device-row-\(device.id.uuidString)",
                label: "\(device.name) \(device.macAddress)"
            )
            .frame(width: 1, height: 1)
        }
    }
}

private struct AccessibilityMarker: NSViewRepresentable {
    let identifier: String
    let label: String

    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        view.setAccessibilityElement(true)
        view.setAccessibilityRole(.group)
        view.setAccessibilityLabel(label)
        view.setAccessibilityIdentifier(identifier)
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        nsView.setAccessibilityElement(true)
        nsView.setAccessibilityRole(.group)
        nsView.setAccessibilityLabel(label)
        nsView.setAccessibilityIdentifier(identifier)
    }
}
