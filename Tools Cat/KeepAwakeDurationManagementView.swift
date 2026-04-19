import AppKit
import SwiftUI

struct KeepAwakeDurationManagementView: View {
    @ObservedObject var session: KeepAwakeDurationManagementSessionModel

    var body: some View {
        listContent
        .padding(24)
        .frame(minWidth: 420, minHeight: 360, alignment: .topLeading)
        .sheet(isPresented: formSheetIsPresented) {
            formSheetContent
        }
        .alert(
            session.pendingDeleteDuration.map {
                KeepAwakeDurationManagementPresentation.deleteConfirmationMessage(
                    durationTitle: $0.menuTitle
                )
            } ?? "",
            isPresented: deleteAlertIsPresented
        ) {
            Button("取消", role: .cancel) {
                session.cancelDelete()
            }
            Button("删除时长", role: .destructive) {
                session.confirmDelete()
            }
        }
        .alert(
            KeepAwakeDurationManagementPresentation.activeDurationDeleteBlockedAlertTitle,
            isPresented: blockedDeleteAlertIsPresented,
            actions: {
                Button("知道了", role: .cancel) {
                    session.dismissBlockedDeleteAlert()
                }
            },
            message: {
                if let duration = session.blockedDeleteDuration {
                    Text(
                        KeepAwakeDurationManagementPresentation
                            .activeDurationDeleteBlockedAlertMessage(durationTitle: duration.menuTitle)
                    )
                }
            }
        )
    }

    private var listContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 8) {
                Text(KeepAwakeDurationManagementPresentation.listTitle)
                    .font(.system(size: 17, weight: .semibold))

                Spacer()

                Button(KeepAwakeDurationManagementPresentation.addButtonTitle) {
                    session.beginAdd()
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("keep-awake-duration-add-button")
            }
            .accessibilityIdentifier("keep-awake-duration-top-actions")

            if session.durations.isEmpty {
                emptyState
            } else {
                populatedListContent
            }
        }
    }

    @ViewBuilder
    private var formSheetContent: some View {
        if let mode = session.currentFormMode {
            formContent(mode: mode)
                .padding(24)
                .frame(width: 320, alignment: .topLeading)
                .accessibilityIdentifier("keep-awake-duration-form-sheet")
        }
    }

    private var populatedListContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 8) {
                Text("定时时长")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)

                Spacer()

                Text("\(session.durations.count) 项")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 2)

            List {
                ForEach(session.durations) { duration in
                    KeepAwakeDurationRow(
                        duration: duration,
                        onEdit: { session.beginEdit(durationID: duration.id) },
                        onDelete: { session.requestDelete(durationID: duration.id) }
                    )
                    .listRowInsets(EdgeInsets(top: 8, leading: 14, bottom: 8, trailing: 14))
                }
            }
            .listStyle(.inset)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .accessibilityIdentifier("keep-awake-duration-list")
            .roundedManagementListChrome()
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("keep-awake-duration-list-surface")
        .overlay(alignment: .topLeading) {
            KeepAwakeDurationAccessibilityMarker(
                identifier: "keep-awake-duration-list-surface",
                label: "常亮时长列表区域"
            )
            .frame(width: 1, height: 1)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "timer")
                .font(.system(size: 30))
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                Text(KeepAwakeDurationManagementPresentation.emptyStateHeading)
                    .font(.system(size: 17, weight: .semibold))

                Text(KeepAwakeDurationManagementPresentation.emptyStateBody)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: 260)
            }

            Button(KeepAwakeDurationManagementPresentation.addButtonTitle) {
                session.beginAdd()
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("keep-awake-duration-empty-add-button")

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("keep-awake-duration-empty-state")
        .overlay(alignment: .topLeading) {
            KeepAwakeDurationAccessibilityMarker(
                identifier: "keep-awake-duration-empty-state",
                label: "还没有常亮时长"
            )
            .frame(width: 1, height: 1)
        }
    }

    private func formContent(mode: KeepAwakeDurationManagementFormMode) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(KeepAwakeDurationManagementPresentation.formTitle(mode: mode))
                .font(.system(size: 17, weight: .semibold))

            fieldGroup(title: KeepAwakeDurationManagementPresentation.minutesFieldTitle) {
                TextField(
                    KeepAwakeDurationManagementPresentation.minutesPlaceholder,
                    text: $session.draftMinutesText
                )
                .textFieldStyle(.roundedBorder)
                .accessibilityIdentifier("keep-awake-duration-minutes-field")
            } message: {
                session.validationMessage
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

                Button(KeepAwakeDurationManagementPresentation.saveButtonTitle) {
                    session.saveDraft()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!session.canSaveDraft)
            }
            .accessibilityIdentifier("keep-awake-duration-form-actions")
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
            get: { session.pendingDeleteDuration != nil },
            set: { isPresented in
                if !isPresented {
                    session.cancelDelete()
                }
            }
        )
    }

    private var blockedDeleteAlertIsPresented: Binding<Bool> {
        Binding(
            get: { session.blockedDeleteDuration != nil },
            set: { isPresented in
                if !isPresented {
                    session.dismissBlockedDeleteAlert()
                }
            }
        )
    }

    private var formSheetIsPresented: Binding<Bool> {
        Binding(
            get: { session.isPresentingForm },
            set: { isPresented in
                if !isPresented {
                    session.cancelForm()
                }
            }
        )
    }
}

private struct KeepAwakeDurationRow: View {
    let duration: ManagedKeepAwakeDuration
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(duration.menuTitle)
                    .font(.system(size: 13, weight: .semibold))
                    .accessibilityIdentifier("keep-awake-duration-title-\(duration.id.uuidString)")

                Text("\(max(1, duration.durationSeconds / 60)) 分钟")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("keep-awake-duration-minutes-\(duration.id.uuidString)")
            }

            Spacer()

            HStack(spacing: 8) {
                Button("编辑", action: onEdit)
                    .buttonStyle(.borderless)
                    .foregroundStyle(Color.accentColor)

                Button("删除", role: .destructive, action: onDelete)
                    .buttonStyle(.borderless)
                    .foregroundStyle(.red)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("keep-awake-duration-row-\(duration.id.uuidString)")
        .overlay(alignment: .topLeading) {
            KeepAwakeDurationAccessibilityMarker(
                identifier: "keep-awake-duration-row-\(duration.id.uuidString)",
                label: duration.menuTitle
            )
            .frame(width: 1, height: 1)
        }
    }

}

private struct KeepAwakeDurationAccessibilityMarker: NSViewRepresentable {
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

private extension View {
    func roundedManagementListChrome() -> some View {
        clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color(nsColor: .separatorColor), lineWidth: 1)
            }
    }
}
