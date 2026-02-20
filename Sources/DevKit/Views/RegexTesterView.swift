import SwiftUI

/// Regex tester tool view.
struct RegexTesterView: View {

    // MARK: - Properties

    @EnvironmentObject private var appState: AppState
    @State private var pattern = ""
    @State private var testString = ""
    @State private var matches: [RegexMatch] = []
    @State private var errorMessage: String?

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("pattern")
                .font(Theme.monoSmall)
                .foregroundStyle(.secondary)

            TextField("regex pattern...", text: $pattern)
                .textFieldStyle(.plain)
                .font(Theme.mono)
                .padding(6)
                .background(Color.primary.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 6))

            Text("test string")
                .font(Theme.monoSmall)
                .foregroundStyle(.secondary)

            TextEditor(text: $testString)
                .font(Theme.monoSmall)
                .frame(height: 80)
                .scrollContentBackground(.hidden)
                .padding(6)
                .background(Color.primary.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 6))

            Button("test") { test() }
                .buttonStyle(.plain)
                .font(Theme.monoSmall)
                .foregroundStyle(Theme.accent)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Theme.accent.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 4))

            if let error = errorMessage {
                Text(error)
                    .font(Theme.monoTiny)
                    .foregroundStyle(Theme.error)
            }

            if !matches.isEmpty {
                HStack {
                    Text("\(matches.count) match\(matches.count == 1 ? "" : "es")")
                        .font(Theme.monoSmall)
                        .foregroundStyle(Theme.success)

                    Spacer()
                }

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 4) {
                        ForEach(Array(matches.enumerated()), id: \.offset) { index, match in
                            matchRow(index: index, match: match)
                        }
                    }
                }
                .frame(maxHeight: 160)
                .padding(6)
                .background(Color.primary.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            } else if errorMessage == nil && !pattern.isEmpty && !testString.isEmpty {
                Text("no matches")
                    .font(Theme.monoSmall)
                    .foregroundStyle(.quaternary)
            }
        }
        .padding(14)
    }

    // MARK: - Subviews

    private func matchRow(index: Int, match: RegexMatch) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Text("match \(index + 1):")
                    .font(Theme.monoTiny)
                    .foregroundStyle(.secondary)

                Text("\"\(match.text)\"")
                    .font(Theme.monoSmall)
                    .foregroundStyle(Theme.accent)
            }

            if !match.groups.isEmpty {
                ForEach(Array(match.groups.enumerated()), id: \.offset) { gIdx, group in
                    HStack(spacing: 4) {
                        Text("  group \(gIdx + 1):")
                            .font(Theme.monoTiny)
                            .foregroundStyle(.quaternary)

                        Text("\"\(group)\"")
                            .font(Theme.monoTiny)
                            .foregroundStyle(Theme.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 2)
    }

    // MARK: - Actions

    private func test() {
        errorMessage = nil
        matches = []
        guard !pattern.isEmpty else {
            errorMessage = "Pattern is empty"
            return
        }
        Task {
            let result = await appState.toolService.testRegex(pattern: pattern, input: testString)
            await MainActor.run {
                switch result {
                case .success(let found):
                    matches = found
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
