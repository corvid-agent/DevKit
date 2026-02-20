import Foundation

/// Represents the available developer tools in the toolkit.
public enum Tool: String, CaseIterable, Identifiable, Sendable {
    case jsonFormatter = "JSON"
    case base64 = "Base64"
    case urlEncoder = "URL"
    case uuidGenerator = "UUID"
    case hashCalculator = "Hash"
    case regexTester = "Regex"
    case timestamp = "Time"
    case colorConverter = "Color"

    // MARK: - Identifiable

    public var id: String { rawValue }

    // MARK: - Display

    /// System image name for the tool icon.
    public var icon: String {
        switch self {
        case .jsonFormatter: return "curlybraces"
        case .base64: return "lock.doc"
        case .urlEncoder: return "link"
        case .uuidGenerator: return "number"
        case .hashCalculator: return "number.circle"
        case .regexTester: return "textformat.abc"
        case .timestamp: return "clock"
        case .colorConverter: return "paintpalette"
        }
    }

    /// Keyboard shortcut number (1-8).
    public var shortcutIndex: Int {
        switch self {
        case .jsonFormatter: return 1
        case .base64: return 2
        case .urlEncoder: return 3
        case .uuidGenerator: return 4
        case .hashCalculator: return 5
        case .regexTester: return 6
        case .timestamp: return 7
        case .colorConverter: return 8
        }
    }
}
