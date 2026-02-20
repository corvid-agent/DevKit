import SwiftUI

/// JSON formatter and validator tool view.
struct JSONFormatterView: View {

    // MARK: - Properties

    @EnvironmentObject private var appState: AppState
    @State private var input = ""
    @State private var output = ""
    @State private var errorMessage: String?

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("input")
                .font(Theme.monoSmall)
                .foregroundStyle(.secondary)

            TextEditor(text: $input)
                .font(Theme.monoSmall)
                .frame(height: 120)
                .scrollContentBackground(.hidden)
                .padding(6)
                .background(Color.primary.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 6))

            HStack(spacing: 8) {
                Button("format") { format() }
                    .buttonStyle(.plain)
                    .font(Theme.monoSmall)
                    .foregroundStyle(Theme.accent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Theme.accent.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 4))

                Button("minify") { minify() }
                    .buttonStyle(.plain)
                    .font(Theme.monoSmall)
                    .foregroundStyle(Theme.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Theme.secondary.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 4))

                Spacer()

                if !output.isEmpty {
                    Button("copy") { appState.copyToClipboard(output) }
                        .buttonStyle(.plain)
                        .font(Theme.monoSmall)
                        .foregroundStyle(.secondary)
                }
            }

            if let error = errorMessage {
                Text(error)
                    .font(Theme.monoTiny)
                    .foregroundStyle(Theme.error)
                    .lineLimit(2)
            }

            if !output.isEmpty {
                Text("output")
                    .font(Theme.monoSmall)
                    .foregroundStyle(.secondary)

                ScrollView {
                    Text(output)
                        .font(Theme.monoSmall)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                }
                .frame(height: 140)
                .padding(6)
                .background(Color.primary.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
        .padding(14)
    }

    // MARK: - Actions

    private func format() {
        errorMessage = nil
        Task {
            let result = await appState.toolService.formatJSON(input)
            await MainActor.run {
                switch result {
                case .success(let formatted):
                    output = formatted
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    output = ""
                }
            }
        }
    }

    private func minify() {
        errorMessage = nil
        Task {
            let result = await appState.toolService.minifyJSON(input)
            await MainActor.run {
                switch result {
                case .success(let minified):
                    output = minified
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    output = ""
                }
            }
        }
    }
}
