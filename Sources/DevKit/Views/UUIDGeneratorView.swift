import SwiftUI

/// UUID generator tool view.
struct UUIDGeneratorView: View {

    // MARK: - Properties

    @EnvironmentObject private var appState: AppState
    @State private var uuids: [String] = []

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("generate v4 uuids")
                .font(Theme.monoSmall)
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                ForEach([1, 5, 10], id: \.self) { count in
                    Button("x\(count)") { generate(count: count) }
                        .buttonStyle(.plain)
                        .font(Theme.monoSmall)
                        .foregroundStyle(Theme.accent)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Theme.accent.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }

                Spacer()

                if !uuids.isEmpty {
                    Button("copy all") { copyAll() }
                        .buttonStyle(.plain)
                        .font(Theme.monoSmall)
                        .foregroundStyle(.secondary)
                }
            }

            if !uuids.isEmpty {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 2) {
                        ForEach(Array(uuids.enumerated()), id: \.offset) { index, uuid in
                            HStack(spacing: 6) {
                                Text(String(format: "%2d.", index + 1))
                                    .font(Theme.monoTiny)
                                    .foregroundStyle(.quaternary)
                                    .frame(width: 24, alignment: .trailing)

                                Text(uuid)
                                    .font(Theme.monoSmall)
                                    .foregroundStyle(.primary)
                                    .textSelection(.enabled)

                                Spacer()

                                Button {
                                    appState.copyToClipboard(uuid)
                                } label: {
                                    Image(systemName: "doc.on.doc")
                                        .font(.system(size: 10))
                                        .foregroundStyle(.tertiary)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.vertical, 2)
                            .padding(.horizontal, 4)
                        }
                    }
                }
                .frame(maxHeight: 280)
                .padding(6)
                .background(Color.primary.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
        .padding(14)
    }

    // MARK: - Actions

    private func generate(count: Int) {
        Task {
            let result = await appState.toolService.generateUUIDs(count: count)
            await MainActor.run { uuids = result }
        }
    }

    private func copyAll() {
        appState.copyToClipboard(uuids.joined(separator: "\n"))
    }
}
