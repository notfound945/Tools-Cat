import XCTest
@testable import Tools_Cat

final class WOLSendPresentationTests: XCTestCase {
    func testIdleMessageHasNoText() {
        XCTAssertNil(WakeSendMessage.idle.text)
    }

    func testSendingMessage() {
        XCTAssertEqual(WakeSendMessage.sending.text, "正在发送唤醒包...")
    }

    func testSuccessMessageIsLocalOnly() {
        let successMessage = WakeSendPresentation.successMessage(for: "AA:BB:CC:DD:EE:FF")
        let bannedTerms = ["唤醒" + "成功", "设备已" + "开启"]

        XCTAssertEqual(successMessage, "已从这台 Mac 发出唤醒包")
        XCTAssertTrue(bannedTerms.allSatisfy { !successMessage.contains($0) })
    }

    func testInvalidMACMessage() {
        XCTAssertEqual(
            WOLSenderError.invalidMAC.userMessage,
            "MAC 地址格式无效，请输入 AA:BB:CC:DD:EE:FF"
        )
    }

    func testSocketFailureMessage() {
        XCTAssertEqual(
            WOLSenderError.socketFailed.userMessage,
            "无法创建本地网络发送通道"
        )
    }

    func testSetsockoptFailureMessage() {
        XCTAssertEqual(
            WOLSenderError.setsockoptFailed.userMessage,
            "无法启用局域网广播发送"
        )
    }

    func testSendFailureMessage() {
        let failureMessage = WOLSenderError.sendFailed.userMessage
        let bannedTerms = ["err" + "no", "send" + "to"]

        XCTAssertEqual(
            failureMessage,
            "未能从这台 Mac 发出唤醒包，请确认这台 Mac 已连接局域网后重试"
        )
        XCTAssertTrue(bannedTerms.allSatisfy { !failureMessage.contains($0) })
    }

    func testSuccessAndFailureMessageTextPassThrough() {
        XCTAssertEqual(WakeSendMessage.success("ok").text, "ok")
        XCTAssertEqual(WakeSendMessage.failure("fail").text, "fail")
    }
}
