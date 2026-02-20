import SwiftUI

@main
struct DevKitApp: App {

    // MARK: - Properties

    @StateObject private var appState = AppState()

    // MARK: - Body

    var body: some Scene {
        MenuBarExtra {
            MenuBarView()
                .environmentObject(appState)
        } label: {
            HStack(spacing: 3) {
                Image(systemName: "wrench.and.screwdriver")
                    .font(.system(size: 12))

                Text("devkit")
                    .font(.system(size: 10, design: .monospaced))
            }
        }
        .menuBarExtraStyle(.window)
    }
}

// MARK: - App State

/// Main application state managing the selected tool.
@MainActor
final class AppState: ObservableObject {

    // MARK: - Published Properties

    @Published var selectedTool: Tool = .jsonFormatter
    @Published var copiedNotification = false

    // MARK: - Services

    let toolService = ToolService()

    // MARK: - Methods

    /// Copies text to the system clipboard and shows a brief notification.
    func copyToClipboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        copiedNotification = true
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.5))
            copiedNotification = false
        }
    }
}
