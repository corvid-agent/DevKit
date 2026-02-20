import Foundation
@testable import DevKit

// MARK: - Model Tests

func runModelTests() {
    // Tool enum
    print("Testing Tool enum...")
    assertEqual(Tool.allCases.count, 8, "Should have 8 tools")

    assertEqual(Tool.jsonFormatter.rawValue, "JSON")
    assertEqual(Tool.base64.rawValue, "Base64")
    assertEqual(Tool.urlEncoder.rawValue, "URL")
    assertEqual(Tool.uuidGenerator.rawValue, "UUID")
    assertEqual(Tool.hashCalculator.rawValue, "Hash")
    assertEqual(Tool.regexTester.rawValue, "Regex")
    assertEqual(Tool.timestamp.rawValue, "Time")
    assertEqual(Tool.colorConverter.rawValue, "Color")

    for tool in Tool.allCases {
        assertFalse(tool.icon.isEmpty, "Tool \(tool.rawValue) should have an icon")
    }

    let indices = Tool.allCases.map { $0.shortcutIndex }
    assertEqual(indices, [1, 2, 3, 4, 5, 6, 7, 8], "Shortcut indices should be 1-8")

    for tool in Tool.allCases {
        assertEqual(tool.id, tool.rawValue, "Tool id should match rawValue")
    }

    // ToolError
    print("Testing ToolError...")
    let inputError = ToolError.invalidInput("bad input")
    assertEqual(inputError.localizedDescription, "bad input")

    let processingError = ToolError.processingFailed("failed")
    assertEqual(processingError.localizedDescription, "failed")

    assertTrue(ToolError.invalidInput("test") == ToolError.invalidInput("test"), "Same errors should be equal")
    assertTrue(ToolError.invalidInput("a") != ToolError.invalidInput("b"), "Different messages should differ")
    assertTrue(ToolError.invalidInput("test") != ToolError.processingFailed("test"), "Different cases should differ")

    // HashResult
    print("Testing HashResult...")
    let hashA = HashResult(md5: "a", sha1: "b", sha256: "c", sha512: "d")
    let hashB = HashResult(md5: "a", sha1: "b", sha256: "c", sha512: "d")
    assertTrue(hashA == hashB, "Same hash results should be equal")

    // RegexMatch
    print("Testing RegexMatch...")
    let matchA = RegexMatch(text: "hello", range: NSRange(location: 0, length: 5), groups: ["h"])
    let matchB = RegexMatch(text: "hello", range: NSRange(location: 0, length: 5), groups: ["h"])
    assertTrue(matchA == matchB, "Same regex matches should be equal")

    // TimestampFormat
    print("Testing TimestampFormat...")
    assertEqual(TimestampFormat.allCases.count, 4, "Should have 4 formats")
    assertEqual(TimestampFormat.iso8601.rawValue, "ISO 8601")
    assertEqual(TimestampFormat.readable.rawValue, "Readable")
    assertEqual(TimestampFormat.short.rawValue, "Short")
    assertEqual(TimestampFormat.utc.rawValue, "UTC")

    // ColorResult
    print("Testing ColorResult...")
    let colorA = ColorResult(hex: "#FF0000", rgb: "rgb(255, 0, 0)", hsl: "hsl(0, 100%, 50%)", red: 1.0, green: 0.0, blue: 0.0)
    let colorB = ColorResult(hex: "#FF0000", rgb: "rgb(255, 0, 0)", hsl: "hsl(0, 100%, 50%)", red: 1.0, green: 0.0, blue: 0.0)
    assertTrue(colorA == colorB, "Same color results should be equal")

    print("Model tests complete.")
}
