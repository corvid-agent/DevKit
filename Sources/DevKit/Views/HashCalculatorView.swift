import SwiftUI

/// Hash calculator tool view.
struct HashCalculatorView: View {

    // MARK: - Properties

    @EnvironmentObject private var appState: AppState
    @State private var input = ""
    @State private var result: HashResult?

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("input text")
                .font(Theme.monoSmall)
                .foregroundStyle(.secondary)

            TextEditor(text: $input)
                .font(Theme.monoSmall)
                .frame(height: 80)
                .scrollContentBackground(.hidden)
                .padding(6)
                .background(Color.primary.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 6))

            Button("compute") { compute() }
                .buttonStyle(.plain)
                .font(Theme.monoSmall)
                .foregroundStyle(Theme.accent)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Theme.accent.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 4))

            if let result = result {
                VStack(alignment: .leading, spacing: 6) {
                    hashRow(label: "md5", value: result.md5)
                    hashRow(label: "sha-1", value: result.sha1)
                    hashRow(label: "sha-256", value: result.sha256)
                    hashRow(label: "sha-512", value: result.sha512)
                }
            }
        }
        .padding(14)
    }

    // MARK: - Subviews

    private func hashRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(label)
                    .font(Theme.monoTiny)
                    .foregroundStyle(Theme.accent)

                Spacer()

                Button("copy") { appState.copyToClipboard(value) }
                    .buttonStyle(.plain)
                    .font(Theme.monoTiny)
                    .foregroundStyle(.tertiary)
            }

            Text(value)
                .font(Theme.monoTiny)
                .foregroundStyle(.primary)
                .textSelection(.enabled)
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .padding(6)
        .background(Color.primary.opacity(0.03))
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }

    // MARK: - Actions

    private func compute() {
        Task {
            let hashes = await appState.toolService.computeHashes(input)
            await MainActor.run { result = hashes }
        }
    }
}
