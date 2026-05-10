import Foundation
import XCTest
@testable import Tools_Cat

@MainActor
final class KeepAwakeMenuStateTests: XCTestCase {
    private let minutes15 = ManagedKeepAwakeDuration(id: UUID(uuidString: "00000000-0000-0000-0000-000000000900")!, durationSeconds: 900)
    private let minutes30 = ManagedKeepAwakeDuration(id: UUID(uuidString: "00000000-0000-0000-0000-000000001800")!, durationSeconds: 1800)
    private let hour1 = ManagedKeepAwakeDuration(id: UUID(uuidString: "00000000-0000-0000-0000-000000003600")!, durationSeconds: 3600)
    private let hours2 = ManagedKeepAwakeDuration(id: UUID(uuidString: "00000000-0000-0000-0000-000000007200")!, durationSeconds: 7200)

    func testIndefinitePresentationShowsCurrentInfiniteStatusRow() {
        let presentation = KeepAwakePresentation(
            confirmedMode: .indefinite,
            pendingAction: nil,
            message: nil,
            reminderAvailability: .available,
            now: referenceDate
        )

        XCTAssertTrue(presentation.isIndefiniteActive)
        XCTAssertNil(presentation.activeTimedDuration)
        XCTAssertEqual(
            presentation.statusLines,
            .init(primary: "当前：无限常亮", secondary: nil)
        )
        XCTAssertEqual(presentation.iconSymbol, "bolt.fill")
        XCTAssertEqual(presentation.buttonToolTip, "常亮已开启：无限常亮")
        XCTAssertFalse(presentation.isPending)
    }

    func testTimedPresentationShowsCountdownInStatusRowOnly() {
        let hourPresentation = KeepAwakePresentation(
            confirmedMode: .timed(
                duration: hours2,
                endDate: referenceDate.addingTimeInterval(60 * 60 + 28 * 60)
            ),
            pendingAction: nil,
            message: nil,
            reminderAvailability: .available,
            now: referenceDate
        )
        let minutePresentation = KeepAwakePresentation(
            confirmedMode: .timed(
                duration: minutes30,
                endDate: referenceDate.addingTimeInterval(28 * 60 + 45)
            ),
            pendingAction: nil,
            message: nil,
            reminderAvailability: .available,
            now: referenceDate
        )
        let secondPresentation = KeepAwakePresentation(
            confirmedMode: .timed(
                duration: minutes15,
                endDate: referenceDate.addingTimeInterval(42)
            ),
            pendingAction: nil,
            message: nil,
            reminderAvailability: .available,
            now: referenceDate
        )

        XCTAssertEqual(hourPresentation.activeTimedDuration, hours2)
        XCTAssertEqual(
            hourPresentation.statusLines,
            .init(primary: "还剩 1 小时 28 分钟", secondary: nil)
        )
        XCTAssertEqual(hourPresentation.buttonToolTip, "常亮已开启：剩余 1 小时 28 分钟")
        XCTAssertEqual(minutePresentation.statusLines, .init(primary: "还剩 28 分钟", secondary: nil))
        XCTAssertEqual(secondPresentation.statusLines, .init(primary: "还剩 42 秒", secondary: nil))
    }

    func testPendingPresentationUsesExactModeSpecificStatusCopy() {
        let cases: [(KeepAwakeMode, KeepAwakePendingAction, String, ManagedKeepAwakeDuration?)] = [
            (.timed(duration: minutes15, endDate: referenceDate.addingTimeInterval(900)), .startingIndefinite, "正在切换为无限常亮...", minutes15),
            (.off, .startingTimed(minutes15), "正在切换为 15 分钟常亮...", nil),
            (.off, .startingTimed(minutes30), "正在切换为 30 分钟常亮...", nil),
            (.off, .startingTimed(hour1), "正在切换为 1 小时常亮...", nil),
            (.off, .startingTimed(hours2), "正在切换为 2 小时常亮...", nil),
            (.timed(duration: minutes30, endDate: referenceDate.addingTimeInterval(1800)), .stopping, "正在关闭常亮...", minutes30),
        ]

        for (confirmedMode, pendingAction, expectedStatus, expectedDuration) in cases {
            let presentation = KeepAwakePresentation(
                confirmedMode: confirmedMode,
                pendingAction: pendingAction,
                message: nil,
                reminderAvailability: .available,
                now: referenceDate
            )

            XCTAssertEqual(
                presentation.statusLines,
                .init(primary: expectedStatus, secondary: nil)
            )
            XCTAssertEqual(presentation.activeTimedDuration, expectedDuration)
            XCTAssertTrue(presentation.isPending)
            XCTAssertEqual(presentation.iconSymbol, "bolt.slash")
            XCTAssertEqual(presentation.buttonToolTip, "常亮状态更新中")
        }
    }

    func testFailurePresentationKeepsMessageVisibleWithoutEndedBanner() {
        let presentation = KeepAwakePresentation(
            confirmedMode: .timed(
                duration: minutes30,
                endDate: referenceDate.addingTimeInterval(20 * 60)
            ),
            pendingAction: nil,
            message: "关闭失败",
            reminderAvailability: .available,
            now: referenceDate
        )

        XCTAssertEqual(presentation.activeTimedDuration, minutes30)
        XCTAssertEqual(presentation.statusLines, .init(primary: "关闭失败", secondary: nil))
        XCTAssertEqual(presentation.iconSymbol, "bolt.fill")
        XCTAssertEqual(presentation.buttonToolTip, "常亮已开启：剩余 20 分钟")
        XCTAssertFalse(presentation.statusLines?.primary.contains("已结束") ?? false)
    }

    func testStopActionVisibilityFollowsConfirmedAndPendingState() {
        let cases: [(KeepAwakeMode, KeepAwakePendingAction?, Bool)] = [
            (.off, nil, false),
            (.off, .startingIndefinite, false),
            (.off, .startingTimed(minutes15), false),
            (.indefinite, .startingTimed(minutes30), true),
            (.timed(duration: minutes30, endDate: referenceDate.addingTimeInterval(30 * 60)), .startingTimed(hour1), true),
            (.indefinite, nil, true),
            (.timed(duration: minutes15, endDate: referenceDate.addingTimeInterval(15 * 60)), .stopping, true),
        ]

        for (confirmedMode, pendingAction, expectedVisibility) in cases {
            let presentation = KeepAwakePresentation(
                confirmedMode: confirmedMode,
                pendingAction: pendingAction,
                message: nil,
                reminderAvailability: .available,
                now: referenceDate
            )

            XCTAssertEqual(presentation.showsStopAction, expectedVisibility)
        }
    }

    private let referenceDate = Date(timeIntervalSinceReferenceDate: 50_000)
}
