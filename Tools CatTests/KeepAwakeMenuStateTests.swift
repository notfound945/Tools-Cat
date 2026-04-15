import Foundation
import XCTest
@testable import Tools_Cat

@MainActor
final class KeepAwakeMenuStateTests: XCTestCase {
    func testIndefinitePresentationShowsCurrentInfiniteStatusRow() {
        let presentation = KeepAwakePresentation(
            confirmedMode: .indefinite,
            pendingAction: nil,
            message: nil,
            now: referenceDate
        )

        XCTAssertTrue(presentation.isIndefiniteActive)
        XCTAssertNil(presentation.activeTimedPreset)
        XCTAssertEqual(presentation.statusText, "当前：无限常亮")
        XCTAssertEqual(presentation.iconSymbol, "bolt.fill")
        XCTAssertEqual(presentation.buttonToolTip, "常亮已开启：无限常亮")
        XCTAssertFalse(presentation.isPending)
    }

    func testTimedPresentationShowsCountdownInStatusRowOnly() {
        let hourPresentation = KeepAwakePresentation(
            confirmedMode: .timed(
                preset: .hours2,
                endDate: referenceDate.addingTimeInterval(60 * 60 + 28 * 60)
            ),
            pendingAction: nil,
            message: nil,
            now: referenceDate
        )
        let minutePresentation = KeepAwakePresentation(
            confirmedMode: .timed(
                preset: .minutes30,
                endDate: referenceDate.addingTimeInterval(28 * 60 + 45)
            ),
            pendingAction: nil,
            message: nil,
            now: referenceDate
        )
        let secondPresentation = KeepAwakePresentation(
            confirmedMode: .timed(
                preset: .minutes15,
                endDate: referenceDate.addingTimeInterval(42)
            ),
            pendingAction: nil,
            message: nil,
            now: referenceDate
        )

        XCTAssertEqual(hourPresentation.activeTimedPreset, .hours2)
        XCTAssertEqual(hourPresentation.statusText, "还剩 1 小时 28 分钟")
        XCTAssertEqual(hourPresentation.buttonToolTip, "常亮已开启：剩余 1 小时 28 分钟")
        XCTAssertEqual(minutePresentation.statusText, "还剩 28 分钟")
        XCTAssertEqual(secondPresentation.statusText, "还剩 42 秒")
    }

    func testPendingPresentationUsesExactModeSpecificStatusCopy() {
        let cases: [(KeepAwakeMode, KeepAwakePendingAction, String, KeepAwakeDurationPreset?)] = [
            (.timed(preset: .minutes15, endDate: referenceDate.addingTimeInterval(900)), .startingIndefinite, "正在切换为无限常亮...", .minutes15),
            (.off, .startingTimed(.minutes15), "正在切换为 15 分钟常亮...", nil),
            (.off, .startingTimed(.minutes30), "正在切换为 30 分钟常亮...", nil),
            (.off, .startingTimed(.hour1), "正在切换为 1 小时常亮...", nil),
            (.off, .startingTimed(.hours2), "正在切换为 2 小时常亮...", nil),
            (.timed(preset: .minutes30, endDate: referenceDate.addingTimeInterval(1800)), .stopping, "正在关闭常亮...", .minutes30),
        ]

        for (confirmedMode, pendingAction, expectedStatus, expectedPreset) in cases {
            let presentation = KeepAwakePresentation(
                confirmedMode: confirmedMode,
                pendingAction: pendingAction,
                message: nil,
                now: referenceDate
            )

            XCTAssertEqual(presentation.statusText, expectedStatus)
            XCTAssertEqual(presentation.activeTimedPreset, expectedPreset)
            XCTAssertTrue(presentation.isPending)
            XCTAssertEqual(presentation.iconSymbol, "bolt.slash")
            XCTAssertEqual(presentation.buttonToolTip, "常亮状态更新中")
        }
    }

    func testFailurePresentationKeepsMessageVisibleWithoutEndedBanner() {
        let presentation = KeepAwakePresentation(
            confirmedMode: .timed(
                preset: .minutes30,
                endDate: referenceDate.addingTimeInterval(20 * 60)
            ),
            pendingAction: nil,
            message: "关闭失败",
            now: referenceDate
        )

        XCTAssertEqual(presentation.activeTimedPreset, .minutes30)
        XCTAssertEqual(presentation.statusText, "关闭失败")
        XCTAssertEqual(presentation.iconSymbol, "bolt.fill")
        XCTAssertEqual(presentation.buttonToolTip, "常亮已开启：剩余 20 分钟")
        XCTAssertFalse(presentation.statusText?.contains("已结束") ?? false)
    }

    func testStopActionVisibilityFollowsConfirmedAndPendingState() {
        let cases: [(KeepAwakeMode, KeepAwakePendingAction?, Bool)] = [
            (.off, nil, false),
            (.off, .startingIndefinite, false),
            (.off, .startingTimed(.minutes15), false),
            (.indefinite, .startingTimed(.minutes30), true),
            (.timed(preset: .minutes30, endDate: referenceDate.addingTimeInterval(30 * 60)), .startingTimed(.hour1), true),
            (.indefinite, nil, true),
            (.timed(preset: .minutes15, endDate: referenceDate.addingTimeInterval(15 * 60)), .stopping, true),
        ]

        for (confirmedMode, pendingAction, expectedVisibility) in cases {
            let presentation = KeepAwakePresentation(
                confirmedMode: confirmedMode,
                pendingAction: pendingAction,
                message: nil,
                now: referenceDate
            )

            XCTAssertEqual(presentation.showsStopAction, expectedVisibility)
        }
    }

    private let referenceDate = Date(timeIntervalSinceReferenceDate: 50_000)
}
