import SwiftUI

/// Shared theme constants for the app.
public enum Theme {

    // MARK: - Colors

    /// Primary accent color used throughout the app.
    public static let accent = Color(red: 0.4, green: 0.9, blue: 0.6)

    /// Secondary accent for highlights.
    public static let secondary = Color(red: 0.3, green: 0.7, blue: 1.0)

    /// Warning / error color.
    public static let error = Color(red: 1.0, green: 0.4, blue: 0.4)

    /// Success color.
    public static let success = Color(red: 0.4, green: 0.9, blue: 0.4)

    // MARK: - Fonts

    /// Monospaced body font.
    public static let mono = Font.system(.body, design: .monospaced)

    /// Monospaced caption font.
    public static let monoSmall = Font.system(.caption, design: .monospaced)

    /// Monospaced caption2 font.
    public static let monoTiny = Font.system(.caption2, design: .monospaced)
}
