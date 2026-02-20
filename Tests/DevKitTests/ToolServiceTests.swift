import Foundation
@testable import DevKit

// MARK: - Test Helpers

enum TestError: Error {
    case failed(String)
}

func assertEqual<T: Equatable>(_ a: T, _ b: T, _ message: String = "", file: String = #file, line: Int = #line) {
    if a != b {
        print("FAIL [\(file):\(line)] assertEqual: \(a) != \(b) \(message)")
    }
}

func assertTrue(_ condition: Bool, _ message: String = "", file: String = #file, line: Int = #line) {
    if !condition {
        print("FAIL [\(file):\(line)] assertTrue: \(message)")
    }
}

func assertFalse(_ condition: Bool, _ message: String = "", file: String = #file, line: Int = #line) {
    if condition {
        print("FAIL [\(file):\(line)] assertFalse: \(message)")
    }
}

// MARK: - ToolService Tests

func runToolServiceTests() async {
    let service = ToolService()

    // JSON Formatter
    print("Testing JSON formatter...")
    let formatResult = await service.formatJSON("{\"b\":2,\"a\":1}")
    if case .success(let formatted) = formatResult {
        assertTrue(formatted.contains("\"a\" : 1"), "Should contain sorted key a")
        assertTrue(formatted.contains("\"b\" : 2"), "Should contain sorted key b")
    }

    let invalidJSON = await service.formatJSON("{invalid json")
    if case .success = invalidJSON {
        print("FAIL: Expected failure for invalid JSON")
    }

    let minifyResult = await service.minifyJSON("{\n  \"name\": \"test\",\n  \"value\": 42\n}")
    if case .success(let minified) = minifyResult {
        assertFalse(minified.contains("\n"), "Minified should not have newlines")
    }

    // Base64
    print("Testing Base64...")
    let encodeResult = await service.encodeBase64("Hello, World!")
    if case .success(let encoded) = encodeResult {
        assertEqual(encoded, "SGVsbG8sIFdvcmxkIQ==")
    }

    let decodeResult = await service.decodeBase64("SGVsbG8sIFdvcmxkIQ==")
    if case .success(let decoded) = decodeResult {
        assertEqual(decoded, "Hello, World!")
    }

    let isB64 = await service.isBase64("SGVsbG8sIFdvcmxkIQ==")
    assertTrue(isB64, "Should detect valid Base64")

    let notB64 = await service.isBase64("Hello, World!")
    assertFalse(notB64, "Should not detect plain text as Base64")

    // URL Encoding
    print("Testing URL encoding...")
    let urlEncResult = await service.encodeURL("hello world & foo=bar")
    if case .success(let urlEncoded) = urlEncResult {
        assertTrue(urlEncoded.contains("hello%20world"), "Should contain encoded space")
    }

    let urlDecResult = await service.decodeURL("hello%20world%26foo%3Dbar")
    if case .success(let urlDecoded) = urlDecResult {
        assertEqual(urlDecoded, "hello world&foo=bar")
    }

    // UUID Generation
    print("Testing UUID generation...")
    let uuids = await service.generateUUIDs(count: 5)
    assertEqual(uuids.count, 5, "Should generate 5 UUIDs")
    for uuid in uuids {
        assertTrue(UUID(uuidString: uuid) != nil, "Should be valid UUID: \(uuid)")
    }
    assertEqual(Set(uuids).count, 5, "All UUIDs should be unique")

    // Hash Calculator
    print("Testing hash calculator...")
    let hashes = await service.computeHashes("hello")
    assertEqual(hashes.md5, "5d41402abc4b2a76b9719d911017c592")
    assertEqual(hashes.sha1, "aaf4c61ddcc5e8a2dabede0f3b482cd9aea9434d")
    assertEqual(hashes.sha256, "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824")
    assertFalse(hashes.sha512.isEmpty, "SHA-512 should not be empty")

    // Regex Tester
    print("Testing regex tester...")
    let regexResult = await service.testRegex(pattern: "\\d+", input: "abc 123 def 456")
    if case .success(let matches) = regexResult {
        assertEqual(matches.count, 2, "Should find 2 matches")
        assertEqual(matches[0].text, "123")
        assertEqual(matches[1].text, "456")
    }

    let groupResult = await service.testRegex(pattern: "(\\w+)@(\\w+)", input: "user@host")
    if case .success(let matches) = groupResult {
        assertEqual(matches.count, 1)
        assertEqual(matches[0].text, "user@host")
        assertEqual(matches[0].groups, ["user", "host"])
    }

    let invalidRegex = await service.testRegex(pattern: "[invalid", input: "test")
    if case .success = invalidRegex {
        print("FAIL: Expected failure for invalid regex")
    }

    // Timestamp Converter
    print("Testing timestamp converter...")
    let tsResult = await service.timestampToDate(1704067200, format: .utc)
    assertEqual(tsResult, "2024-01-01T00:00:00Z")

    let dateResult = await service.dateToTimestamp("2024-01-01")
    if case .success(let ts) = dateResult {
        assertTrue(ts > 0, "Timestamp should be positive")
    }

    let invalidDate = await service.dateToTimestamp("not a date")
    if case .success = invalidDate {
        print("FAIL: Expected failure for invalid date")
    }

    // Color Converter
    print("Testing color converter...")
    let hexResult = await service.convertColor("#FF5733")
    if case .success(let color) = hexResult {
        assertEqual(color.hex, "#FF5733")
        assertEqual(color.rgb, "rgb(255, 87, 51)")
        assertFalse(color.hsl.isEmpty, "HSL should not be empty")
    }

    let shortHexResult = await service.convertColor("#FFF")
    if case .success(let color) = shortHexResult {
        assertEqual(color.hex, "#FFFFFF")
        assertEqual(color.rgb, "rgb(255, 255, 255)")
    }

    let rgbResult = await service.convertColor("rgb(255, 0, 0)")
    if case .success(let color) = rgbResult {
        assertEqual(color.hex, "#FF0000")
    }

    let hslResult = await service.convertColor("hsl(0, 100%, 50%)")
    if case .success(let color) = hslResult {
        assertEqual(color.hex, "#FF0000")
    }

    let invalidColor = await service.convertColor("not a color")
    if case .success = invalidColor {
        print("FAIL: Expected failure for invalid color")
    }

    print("ToolService tests complete.")
}
