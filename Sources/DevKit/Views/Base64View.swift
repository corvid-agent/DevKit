import SwiftUI

/// Base64 encoder/decoder tool view.
struct Base64View: View {

    // MARK: - Properties

    @EnvironmentObject private var appState: AppState
    @State private var input = ""
    @State private var output = ""
    @State private var errorMessage: String?
    @State private var isBase64Detected = false

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("input")
                    .font(Theme.monoSmall)
                    .foregroundStyle(.secondary)

                Spacer()

                if isBase64Detected {
                    Text("base64 detected")
                        .font(Theme.monoTiny)
                        .foregroundStyle(Theme.accent)
                }
            }

            TextEditor(text: $input)
                .font(Theme.monoSmall)
                .frame(height: 100)
                .scrollContentBackground(.hidden)
                .padding(6)
                .background(Color.primary.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .onChange(of: input) { _ in detectBase64() }

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
                .frame(height: 100)
                .padding(6)
                .background(Color.primary.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
        .padding(14)
    }

    // MARK: - Actions

    private func detectBase64() {
        Task {
            let detected = await appState.toolService.isBase64(input)
            await MainActor.run { isBase64Detected = detected }
        }
    }

    private func encode() {
        errorMessage = nil
        Task {
            let result = await appState.toolService.encodeBase64(input)
            await MainActor.run {
                switch result {
                case .success(let encoded): output = encoded
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    output = ""
                }
            }
        }
    }

    private func decode() {
        errorMessage = nil
        Task {
            let result = await appState.toolService.decodeBase64(input)
            await MainActor.run {
                switch result {
                case .success(let decoded): output = decoded
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    output = ""
                }
            }
        }
    }
}
