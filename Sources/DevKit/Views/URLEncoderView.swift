import SwiftUI

/// URL encoder/decoder tool view.
struct URLEncoderView: View {

    // MARK: - Properties

    @EnvironmentObject private var appState: AppState
    @State private var input = ""
    @State private var encoded = ""
    @State private var decoded = ""
    @State private var errorMessage: String?

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("input")
                .font(Theme.monoSmall)
                .foregroundStyle(.secondary)

            TextEditor(text: $input)
                .font(Theme.monoSmall)
                .frame(height: 80)
                .scrollContentBackground(.hidden)
                .padding(6)
                .background(Color.primary.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 6))

            HStack(spacing: 8) {
                Button("encode") { encode() }
                    .buttonStyle(.plain)
                    .font(Theme.monoSmall)
                    .foregroundStyle(Theme.accent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Theme.accent.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 4))

                Button("decode") { decode() }
                    .buttonStyle(.plain)
                    .font(Theme.monoSmall)
                    .foregroundStyle(Theme.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Theme.secondary.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 4))

                Spacer()
            }

            if let error = errorMessage {
                Text(error)
                    .font(Theme.monoTiny)
                    .foregroundStyle(Theme.error)
            }

            if !encoded.isEmpty {
                resultRow(label: "encoded", value: encoded)
            }

            if !decoded.isEmpty {
                resultRow(label: "decoded", value: decoded)
            }
        }
        .padding(14)
    }

    // MARK: - Subviews

    private func resultRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(Theme.monoSmall)
                    .foregroundStyle(.secondary)

                Spacer()

                Button("copy") { appState.copyToClipboard(value) }
                    .buttonStyle(.plain)
                    .font(Theme.monoTiny)
                    .foregroundStyle(.secondary)
            }

            ScrollView {
                Text(value)
                    .font(Theme.monoSmall)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
            }
            .frame(height: 60)
            .padding(6)
            .background(Color.primary.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }

    // MARK: - Actions

    private func encode() {
        errorMessage = nil
        Task {
            let result = await appState.toolService.encodeURL(input)
            await MainActor.run {
                switch result {
                case .success(let value):
                    encoded = value
                    decoded = ""
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func decode() {
        errorMessage = nil
        Task {
            let result = await appState.toolService.decodeURL(input)
            await MainActor.run {
                switch result {
                case .success(let value):
                    decoded = value
                    encoded = ""
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
