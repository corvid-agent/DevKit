import Foundation
import CryptoKit

/// Actor responsible for all developer tool computations.
public actor ToolService {

    // MARK: - Initializers

    public init() {}

    // MARK: - JSON Formatter

    /// Formats JSON string with indentation.
    public func formatJSON(_ input: String) -> Result<String, ToolError> {
        guard let data = input.data(using: .utf8) else {
            return .failure(.invalidInput("Input is not valid UTF-8"))
        }

        do {
            let object = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
            let formatted = try JSONSerialization.data(
                withJSONObject: object,
                options: [.prettyPrinted, .sortedKeys]
            )
            guard let result = String(data: formatted, encoding: .utf8) else {
                return .failure(.processingFailed("Could not encode formatted JSON"))
            }
            return .success(result)
        } catch {
            return .failure(.invalidInput("Invalid JSON: \(error.localizedDescription)"))
        }
    }

    /// Minifies JSON string by removing whitespace.
    public func minifyJSON(_ input: String) -> Result<String, ToolError> {
        guard let data = input.data(using: .utf8) else {
            return .failure(.invalidInput("Input is not valid UTF-8"))
        }

        do {
            let object = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
            let minified = try JSONSerialization.data(
                withJSONObject: object,
                options: [.sortedKeys]
            )
            guard let result = String(data: minified, encoding: .utf8) else {
                return .failure(.processingFailed("Could not encode minified JSON"))
            }
            return .success(result)
        } catch {
            return .failure(.invalidInput("Invalid JSON: \(error.localizedDescription)"))
        }
    }

    // MARK: - Base64

    /// Encodes a string to Base64.
    public func encodeBase64(_ input: String) -> Result<String, ToolError> {
        guard let data = input.data(using: .utf8) else {
            return .failure(.invalidInput("Input is not valid UTF-8"))
        }
        return .success(data.base64EncodedString())
    }

    /// Decodes a Base64 string.
    public func decodeBase64(_ input: String) -> Result<String, ToolError> {
        let cleaned = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let data = Data(base64Encoded: cleaned) else {
            return .failure(.invalidInput("Input is not valid Base64"))
        }
        guard let result = String(data: data, encoding: .utf8) else {
            return .failure(.processingFailed("Decoded data is not valid UTF-8"))
        }
        return .success(result)
    }

    /// Detects whether the input is likely Base64 encoded.
    public func isBase64(_ input: String) -> Bool {
        let cleaned = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return false }
        let base64Pattern = "^[A-Za-z0-9+/]*={0,2}$"
        guard cleaned.range(of: base64Pattern, options: .regularExpression) != nil else {
            return false
        }
        return cleaned.count % 4 == 0 && Data(base64Encoded: cleaned) != nil
    }

    // MARK: - URL Encoding

    /// URL-encodes a string.
    public func encodeURL(_ input: String) -> Result<String, ToolError> {
        guard let encoded = input.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return .failure(.processingFailed("Could not URL-encode input"))
        }
        return .success(encoded)
    }

    /// Decodes a URL-encoded string.
    public func decodeURL(_ input: String) -> Result<String, ToolError> {
        guard let decoded = input.removingPercentEncoding else {
            return .failure(.invalidInput("Input is not valid URL-encoded text"))
        }
        return .success(decoded)
    }

    // MARK: - UUID Generator

    /// Generates one or more v4 UUIDs.
    public func generateUUIDs(count: Int) -> [String] {
        (0..<count).map { _ in UUID().uuidString }
    }

    // MARK: - Hash Calculator

    /// Computes all supported hashes for the given input.
    public func computeHashes(_ input: String) -> HashResult {
        guard let data = input.data(using: .utf8) else {
            return HashResult(md5: "", sha1: "", sha256: "", sha512: "")
        }

        let md5 = Insecure.MD5.hash(data: data)
            .map { String(format: "%02x", $0) }.joined()
        let sha1 = Insecure.SHA1.hash(data: data)
            .map { String(format: "%02x", $0) }.joined()
        let sha256 = SHA256.hash(data: data)
            .map { String(format: "%02x", $0) }.joined()
        let sha512 = SHA512.hash(data: data)
            .map { String(format: "%02x", $0) }.joined()

        return HashResult(md5: md5, sha1: sha1, sha256: sha256, sha512: sha512)
    }

    // MARK: - Regex Tester

    /// Tests a regex pattern against input text and returns matches.
    public func testRegex(pattern: String, input: String) -> Result<[RegexMatch], ToolError> {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(input.startIndex..., in: input)
            let results = regex.matches(in: input, options: [], range: range)

            let matches = results.map { result -> RegexMatch in
                let matchRange = Range(result.range, in: input)!
                let matchText = String(input[matchRange])

                var groups: [String] = []
                for i in 1..<result.numberOfRanges {
                    if let groupRange = Range(result.range(at: i), in: input) {
                        groups.append(String(input[groupRange]))
                    } else {
                        groups.append("")
                    }
                }

                return RegexMatch(
                    text: matchText,
                    range: result.range,
                    groups: groups
                )
            }

            return .success(matches)
        } catch {
            return .failure(.invalidInput("Invalid regex: \(error.localizedDescription)"))
        }
    }

    // MARK: - Timestamp Converter

    /// Converts a Unix timestamp to a formatted date string.
    public func timestampToDate(_ timestamp: TimeInterval, format: TimestampFormat) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current

        switch format {
        case .iso8601:
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        case .readable:
            formatter.dateStyle = .full
            formatter.timeStyle = .full
        case .short:
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        case .utc:
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            formatter.timeZone = TimeZone(identifier: "UTC")
        }

        return formatter.string(from: date)
    }

    /// Converts a date string to a Unix timestamp.
    public func dateToTimestamp(_ dateString: String) -> Result<TimeInterval, ToolError> {
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ss'Z'",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd",
            "MM/dd/yyyy HH:mm:ss",
            "MM/dd/yyyy",
        ]

        for format in formats {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            formatter.timeZone = TimeZone.current
            if let date = formatter.date(from: dateString) {
                return .success(date.timeIntervalSince1970)
            }
        }

        return .failure(.invalidInput("Could not parse date. Supported formats: ISO 8601, yyyy-MM-dd HH:mm:ss, yyyy-MM-dd, MM/dd/yyyy"))
    }

    // MARK: - Color Converter

    /// Parses a color string (hex, RGB, or HSL) and returns all formats.
    public func convertColor(_ input: String) -> Result<ColorResult, ToolError> {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)

        // Try hex
        if let (r, g, b) = parseHex(trimmed) {
            return .success(colorResult(r: r, g: g, b: b))
        }

        // Try rgb(r, g, b)
        if let (r, g, b) = parseRGB(trimmed) {
            return .success(colorResult(r: r, g: g, b: b))
        }

        // Try hsl(h, s%, l%)
        if let (r, g, b) = parseHSL(trimmed) {
            return .success(colorResult(r: r, g: g, b: b))
        }

        return .failure(.invalidInput("Could not parse color. Supported: #RRGGBB, rgb(r,g,b), hsl(h,s%,l%)"))
    }

    // MARK: - Color Helpers

    private func parseHex(_ input: String) -> (Double, Double, Double)? {
        var hex = input
        if hex.hasPrefix("#") { hex = String(hex.dropFirst()) }

        guard hex.count == 6 || hex.count == 3 else { return nil }
        guard hex.allSatisfy({ $0.isHexDigit }) else { return nil }

        if hex.count == 3 {
            hex = hex.map { "\($0)\($0)" }.joined()
        }

        guard let value = UInt64(hex, radix: 16) else { return nil }

        let r = Double((value >> 16) & 0xFF) / 255.0
        let g = Double((value >> 8) & 0xFF) / 255.0
        let b = Double(value & 0xFF) / 255.0
        return (r, g, b)
    }

    private func parseRGB(_ input: String) -> (Double, Double, Double)? {
        let pattern = "^rgb\\s*\\(\\s*(\\d{1,3})\\s*,\\s*(\\d{1,3})\\s*,\\s*(\\d{1,3})\\s*\\)$"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return nil
        }

        let range = NSRange(input.startIndex..., in: input)
        guard let match = regex.firstMatch(in: input, options: [], range: range) else {
            return nil
        }

        guard let rRange = Range(match.range(at: 1), in: input),
              let gRange = Range(match.range(at: 2), in: input),
              let bRange = Range(match.range(at: 3), in: input),
              let r = Int(input[rRange]), r <= 255,
              let g = Int(input[gRange]), g <= 255,
              let b = Int(input[bRange]), b <= 255 else {
            return nil
        }

        return (Double(r) / 255.0, Double(g) / 255.0, Double(b) / 255.0)
    }

    private func parseHSL(_ input: String) -> (Double, Double, Double)? {
        let pattern = "^hsl\\s*\\(\\s*(\\d{1,3})\\s*,\\s*(\\d{1,3})%?\\s*,\\s*(\\d{1,3})%?\\s*\\)$"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return nil
        }

        let range = NSRange(input.startIndex..., in: input)
        guard let match = regex.firstMatch(in: input, options: [], range: range) else {
            return nil
        }

        guard let hRange = Range(match.range(at: 1), in: input),
              let sRange = Range(match.range(at: 2), in: input),
              let lRange = Range(match.range(at: 3), in: input),
              let h = Double(input[hRange]),
              let s = Double(input[sRange]),
              let l = Double(input[lRange]) else {
            return nil
        }

        return hslToRGB(h: h, s: s / 100.0, l: l / 100.0)
    }

    private func hslToRGB(h: Double, s: Double, l: Double) -> (Double, Double, Double) {
        guard s > 0 else { return (l, l, l) }

        let c = (1.0 - abs(2.0 * l - 1.0)) * s
        let hPrime = h / 60.0
        let x = c * (1.0 - abs(hPrime.truncatingRemainder(dividingBy: 2.0) - 1.0))
        let m = l - c / 2.0

        let (r1, g1, b1): (Double, Double, Double)
        switch hPrime {
        case 0..<1: (r1, g1, b1) = (c, x, 0)
        case 1..<2: (r1, g1, b1) = (x, c, 0)
        case 2..<3: (r1, g1, b1) = (0, c, x)
        case 3..<4: (r1, g1, b1) = (0, x, c)
        case 4..<5: (r1, g1, b1) = (x, 0, c)
        default:    (r1, g1, b1) = (c, 0, x)
        }

        return (r1 + m, g1 + m, b1 + m)
    }

    private func rgbToHSL(r: Double, g: Double, b: Double) -> (Double, Double, Double) {
        let maxC = max(r, g, b)
        let minC = min(r, g, b)
        let delta = maxC - minC
        let l = (maxC + minC) / 2.0

        guard delta > 0.001 else { return (0, 0, l * 100.0) }

        let s = delta / (1.0 - abs(2.0 * l - 1.0))
        let h: Double
        if maxC == r {
            h = 60.0 * (((g - b) / delta).truncatingRemainder(dividingBy: 6.0))
        } else if maxC == g {
            h = 60.0 * (((b - r) / delta) + 2.0)
        } else {
            h = 60.0 * (((r - g) / delta) + 4.0)
        }

        return (h < 0 ? h + 360 : h, s * 100.0, l * 100.0)
    }

    private func colorResult(r: Double, g: Double, b: Double) -> ColorResult {
        let ri = Int(round(r * 255))
        let gi = Int(round(g * 255))
        let bi = Int(round(b * 255))
        let hex = String(format: "#%02X%02X%02X", ri, gi, bi)
        let rgb = "rgb(\(ri), \(gi), \(bi))"
        let (h, s, l) = rgbToHSL(r: r, g: g, b: b)
        let hsl = "hsl(\(Int(round(h))), \(Int(round(s)))%, \(Int(round(l)))%)"

        return ColorResult(
            hex: hex,
            rgb: rgb,
            hsl: hsl,
            red: r,
            green: g,
            blue: b
        )
    }
}

// MARK: - Supporting Types

/// Errors that can occur during tool operations.
public enum ToolError: Error, LocalizedError, Sendable, Equatable {
    case invalidInput(String)
    case processingFailed(String)

    public var errorDescription: String? {
        switch self {
        case .invalidInput(let message): return message
        case .processingFailed(let message): return message
        }
    }
}

/// Result of hash computations.
public struct HashResult: Sendable, Equatable {
    public let md5: String
    public let sha1: String
    public let sha256: String
    public let sha512: String
}

/// A single regex match with its groups.
public struct RegexMatch: Sendable, Equatable {
    public let text: String
    public let range: NSRange
    public let groups: [String]
}

/// Supported timestamp display formats.
public enum TimestampFormat: String, CaseIterable, Sendable {
    case iso8601 = "ISO 8601"
    case readable = "Readable"
    case short = "Short"
    case utc = "UTC"
}

/// Result of color conversion.
public struct ColorResult: Sendable, Equatable {
    public let hex: String
    public let rgb: String
    public let hsl: String
    public let red: Double
    public let green: Double
    public let blue: Double
}
