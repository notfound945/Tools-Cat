import Foundation

enum DeviceLibraryManagementPresentation {
    static let windowTitle = "设备库"
    static let listTitle = "已保存设备"
    static let emptyStateHeading = "还没有已保存设备"
    static let emptyStateBody = "点击“添加设备”创建第一台设备。名称和 MAC 地址为必填项，备注为可选。"
    static let saveButtonTitle = "保存设备"

    static func reorderButtonTitle(isReordering: Bool) -> String {
        isReordering ? "完成排序" : "重新排序"
    }

    static func formTitle(mode: DeviceLibraryFormMode) -> String {
        switch mode {
        case .add:
            "添加设备"
        case .edit:
            "编辑设备"
        }
    }

    static func deleteConfirmationMessage(deviceName: String) -> String {
        "删除设备: 删除后不会恢复。确定删除“\(deviceName)”吗？"
    }
}
