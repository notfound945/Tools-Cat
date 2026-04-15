import Foundation

enum KeepAwakeDurationManagementPresentation {
    static let windowTitle = "常亮时长"
    static let listTitle = "管理常亮时长"
    static let addButtonTitle = "添加时长"
    static let saveButtonTitle = "保存时长"
    static let minutesFieldTitle = "时长（分钟）"
    static let minutesPlaceholder = "请输入分钟数"
    static let emptyStateHeading = "还没有时长"
    static let emptyStateBody = "添加新的常亮时长后，会按时长从短到长排序。"
    static let loadErrorMessage = "无法加载时长，请稍后重试"
    static let saveErrorMessage = "无法保存时长，请稍后重试"
    static let deleteErrorMessage = "无法删除时长，请稍后重试"
    static let missingMinutesMessage = "请填写时长"
    static let invalidMinutesMessage = "请输入正整数分钟"
    static let duplicateDurationMessage = "该时长已存在"

    static func formTitle(mode: KeepAwakeDurationManagementFormMode) -> String {
        switch mode {
        case .add:
            "添加时长"
        case .edit:
            "编辑时长"
        }
    }

    static func deleteConfirmationMessage(durationTitle: String) -> String {
        "删除时长: 删除后不会恢复。确定删除“\(durationTitle)”吗？"
    }
}
