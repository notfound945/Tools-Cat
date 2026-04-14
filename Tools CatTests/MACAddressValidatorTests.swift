import XCTest
@testable import Tools_Cat

final class MACAddressValidatorTests: XCTestCase {
    func testEmptyInput() {
        let result = ManualMACValidator.validate("")

        XCTAssertEqual(result, .empty)
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.userMessage, "请填写 MAC 地址")
    }

    func testWhitespaceOnlyInput() {
        let result = ManualMACValidator.validate("   ")

        XCTAssertEqual(result, .empty)
        XCTAssertEqual(result.userMessage, "请填写 MAC 地址")
    }

    func testInvalidCharacters() {
        let result = ManualMACValidator.validate("AA:BB:CC:DD:EE:G1")

        XCTAssertEqual(result, .invalidCharacters)
        XCTAssertEqual(result.userMessage, "MAC 地址只能包含 0-9、A-F 和冒号")
    }

    func testMissingSeparators() {
        let result = ManualMACValidator.validate("AA11BB22CC33")

        XCTAssertEqual(result, .missingSeparators)
        XCTAssertEqual(result.userMessage, "请输入冒号分隔格式，例如 AA:BB:CC:DD:EE:FF")
    }

    func testWrongGroupCount() {
        let result = ManualMACValidator.validate("AA:BB:CC:DD:EE")

        XCTAssertEqual(result, .wrongGroupCount)
        XCTAssertEqual(result.userMessage, "MAC 地址必须是 6 组两位十六进制字符")
    }

    func testWrongByteLength() {
        let result = ManualMACValidator.validate("AA:BBB:CC:DD:EE:FF")

        XCTAssertEqual(result, .wrongByteLength)
        XCTAssertEqual(result.userMessage, "MAC 地址必须是 6 组两位十六进制字符")
    }

    func testInvalidHexInsideGroup() {
        let result = ManualMACValidator.validate("AA:BB:CC:DD:EE:ZG")

        XCTAssertEqual(result, .invalidCharacters)
        XCTAssertEqual(result.userMessage, "MAC 地址只能包含 0-9、A-F 和冒号")
    }

    func testLowercaseValidInput() {
        let result = ManualMACValidator.validate("aa:bb:cc:dd:ee:ff")

        XCTAssertEqual(result, .valid("AA:BB:CC:DD:EE:FF"))
        XCTAssertTrue(result.isValid)
        XCTAssertNil(result.userMessage)
    }

    func testUppercaseValidInput() {
        let result = ManualMACValidator.validate("AA:BB:CC:DD:EE:FF")

        XCTAssertEqual(result, .valid("AA:BB:CC:DD:EE:FF"))
        XCTAssertTrue(result.isValid)
        XCTAssertNil(result.userMessage)
    }
}
