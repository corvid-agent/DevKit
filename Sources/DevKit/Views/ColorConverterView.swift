import SwiftUI

/// Color converter tool view.
struct ColorConverterView: View {

    // MARK: - Properties

    @EnvironmentObject private var appState: AppState
    @State private var input = ""
    @State private var result: ColorResult?
    @State private var errorMessage: String?

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("input (hex, rgb, or hsl)")
                .font(Theme.monoSmall)
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                TextField("#FF5733 or rgb(255,87,51) or hsl(11,100%,60%)", text: $input)
                    .textFieldStyle(.plain)
                    .font(Theme.monoSmall)
                    .padding(6)
                    .background(Color.primary.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                Button("convert") { convert() }
                    .buttonStyle(.plain)
                    .font(Theme.monoSmall)
                    .foregroundStyle(Theme.accent)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Theme.accent.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }

            if let error = errorMessage {
                Text(error)
                    .font(Theme.monoTiny)
                    .foregroundStyle(Theme.error)
            }

            if let result = result {
                // Color preview
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(red: result.red, green: result.green, blue: result.blue))
                        .frame(width: 64, height: 64)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(Color.primary.opacity(0.2), lineWidth: 1)
                        )

                    VStack(alignment: .leading, spacing: 6) {
                        colorFormatRow(label: "hex", value: result.hex)
                        colorFormatRow(label: "rgb", value: result.rgb)
                        colorFormatRow(label: "hsl", value: result.hsl)
                    }
                }
                .padding(8)
                .background(Color.primary.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
        .padding(14)
    }

    // MARK: - Subviews

    private func colorFormatRow(label: String, value: String) -> some View {
        HStack(spacing: 6) {
            Text(label)
                .font(Theme.monoTiny)
                .foregroundStyle(.secondary)
                .frame(width: 28, alignment: .leading)

            Text(value)
                .font(Theme.monoSmall)
                .foregroundStyle(.primary)
                .textSelection(.enabled)

            Spacer()

            Button {
                appState.copyToClipboard(value)
            } label: {
                Image(systemName: "doc.on.doc")
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Actions

    private func convert() {
        errorMessage = nil
        result = nil
        Task {
            let conversionResult = await appState.toolService.convertColor(input)
            await MainActor.run {
                switch conversionResult {
                case .success(let color):
                    result = color
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
