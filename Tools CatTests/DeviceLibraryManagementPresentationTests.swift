import XCTest
@testable import Tools_Cat

final class DeviceLibraryManagementPresentationTests: XCTestCase {
    func testStaticCopyMatchesUISpec() {
        XCTAssertEqual(DeviceLibraryManagementPresentation.windowTitle, "设备库")
        XCTAssertEqual(DeviceLibraryManagementPresentation.listTitle, "已保存设备")
        XCTAssertEqual(DeviceLibraryManagementPresentation.emptyStateHeading, "还没有已保存设备")
        XCTAssertEqual(
            DeviceLibraryManagementPresentation.emptyStateBody,
            "点击“添加设备”创建第一台设备。名称和 MAC 地址为必填项，备注为可选。"
        )
        XCTAssertEqual(DeviceLibraryManagementPresentation.saveButtonTitle, "保存设备")
    }

    func testReorderButtonTitles() {
        XCTAssertEqual(
            DeviceLibraryManagementPresentation.reorderButtonTitle(isReordering: false),
            "重新排序"
        )
        XCTAssertEqual(
            DeviceLibraryManagementPresentation.reorderButtonTitle(isReordering: true),
            "完成排序"
        )
    }

    func testDeleteConfirmationIncludesDeviceName() {
        XCTAssertEqual(
            DeviceLibraryManagementPresentation.deleteConfirmationMessage(deviceName: "书房 Mac mini"),
            "删除设备: 删除后不会恢复。确定删除“书房 Mac mini”吗？"
        )
    }

    func testFormTitleMatchesAddAndEditModesOnly() {
        XCTAssertEqual(
            DeviceLibraryManagementPresentation.formTitle(mode: .add),
            "添加设备"
        )
        XCTAssertEqual(
            DeviceLibraryManagementPresentation.formTitle(mode: .edit(deviceID: UUID())),
            "编辑设备"
        )
    }
}
