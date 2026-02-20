import SwiftUI

/// Menu bar popup view containing the tool selector and active tool view.
struct MenuBarView: View {

    // MARK: - Properties

    @EnvironmentObject private var appState: AppState

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerView
            Divider().opacity(0.3)
            toolPicker
            Divider().opacity(0.3)
            toolContent
            Divider().opacity(0.3)
            footerView
        }
        .frame(width: 420)
        .background(Color(nsColor: .windowBackgroundColor))
        .background { keyboardShortcuts }
    }

    // MARK: - Header

    private var headerView: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 1) {
                Text("devkit")
                    .font(.system(.title3, design: .monospaced, weight: .bold))
                    .foregroundStyle(Theme.accent)

                Text(appState.selectedTool.rawValue.lowercased())
                    .font(Theme.monoSmall)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if appState.copiedNotification {
                Text("copied!")
                    .font(Theme.monoSmall)
                    .foregroundStyle(Theme.success)
                    .transition(.opacity)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .animation(.easeInOut(duration: 0.2), value: appState.copiedNotification)
    }

    // MARK: - Tool Picker

    private var toolPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(Tool.allCases) { tool in
                    Button(action: { appState.selectedTool = tool }) {
                        VStack(spacing: 2) {
                            Image(systemName: tool.icon)
                                .font(.system(size: 11))
                            Text(tool.rawValue.lowercased())
                                .font(Theme.monoTiny)
                        }
                        .foregroundStyle(appState.selectedTool == tool ? Theme.accent : .secondary)
                        .frame(width: 52, height: 36)
                        .background(
                            appState.selectedTool == tool
                                ? Theme.accent.opacity(0.1)
                                : Color.clear
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Tool Content

    @ViewBuilder
    private var toolContent: some View {
        switch appState.selectedTool {
        case .jsonFormatter:
            JSONFormatterView()
        case .base64:
            Base64View()
        case .urlEncoder:
            URLEncoderView()
        case .uuidGenerator:
            UUIDGeneratorView()
        case .hashCalculator:
            HashCalculatorView()
        case .regexTester:
            RegexTesterView()
        case .timestamp:
            TimestampView()
        case .colorConverter:
            ColorConverterView()
        }
    }

    // MARK: - Footer

    private var footerView: some View {
        HStack(spacing: 12) {
            Text("cmd+1-8 switch tools")
                .font(Theme.monoTiny)
                .foregroundStyle(.quaternary)

            Spacer()

            Button(action: { NSApplication.shared.terminate(nil) }) {
                Text("quit")
                    .font(Theme.monoSmall)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    // MARK: - Keyboard Shortcuts

    private var keyboardShortcuts: some View {
        VStack {
            ForEach(Tool.allCases) { tool in
                Button(tool.rawValue) { appState.selectedTool = tool }
                    .keyboardShortcut(
                        KeyEquivalent(Character(String(tool.shortcutIndex))),
                        modifiers: .command
                    )
            }
        }
        .opacity(0)
        .allowsHitTesting(false)
    }
}
