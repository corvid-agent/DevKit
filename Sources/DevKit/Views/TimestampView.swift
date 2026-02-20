import SwiftUI

/// Unix timestamp converter tool view.
struct TimestampView: View {

    // MARK: - Properties

    @EnvironmentObject private var appState: AppState
    @State private var currentTimestamp: TimeInterval = Date().timeIntervalSince1970
    @State private var timestampInput = ""
    @State private var dateInput = ""
    @State private var convertedDates: [String] = []
    @State private var convertedTimestamp = ""
    @State private var errorMessage: String?
    @State private var timerTask: Task<Void, Never>?

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Live timestamp
            VStack(alignment: .leading, spacing: 4) {
                Text("current unix timestamp")
                    .font(Theme.monoSmall)
                    .foregroundStyle(.secondary)

                HStack {
                    Text(String(Int(currentTimestamp)))
                        .font(.system(.title2, design: .monospaced, weight: .bold))
                        .foregroundStyle(Theme.accent)
                        .textSelection(.enabled)

                    Spacer()

                    Button("copy") {
                        appState.copyToClipboard(String(Int(currentTimestamp)))
                    }
                    .buttonStyle(.plain)
                    .font(Theme.monoSmall)
                    .foregroundStyle(.secondary)
                }
            }
            .padding(8)
            .background(Color.primary.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 6))

            Divider().opacity(0.3)

            // Timestamp to date
            VStack(alignment: .leading, spacing: 4) {
                Text("timestamp to date")
                    .font(Theme.monoSmall)
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    TextField("unix timestamp...", text: $timestampInput)
                        .textFieldStyle(.plain)
                        .font(Theme.mono)
                        .padding(6)
                        .background(Color.primary.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 6))

                    Button("convert") { convertTimestamp() }
                        .buttonStyle(.plain)
                        .font(Theme.monoSmall)
                        .foregroundStyle(Theme.accent)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Theme.accent.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }

                ForEach(Array(convertedDates.enumerated()), id: \.offset) { _, date in
                    Text(date)
                        .font(Theme.monoTiny)
                        .foregroundStyle(.primary)
                        .textSelection(.enabled)
                }
            }

            Divider().opacity(0.3)

            // Date to timestamp
            VStack(alignment: .leading, spacing: 4) {
                Text("date to timestamp")
                    .font(Theme.monoSmall)
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    TextField("yyyy-MM-dd HH:mm:ss", text: $dateInput)
                        .textFieldStyle(.plain)
                        .font(Theme.mono)
                        .padding(6)
                        .background(Color.primary.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 6))

                    Button("convert") { convertDate() }
                        .buttonStyle(.plain)
                        .font(Theme.monoSmall)
                        .foregroundStyle(Theme.accent)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Theme.accent.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }

                if !convertedTimestamp.isEmpty {
                    HStack {
                        Text(convertedTimestamp)
                            .font(Theme.monoSmall)
                            .foregroundStyle(Theme.accent)
                            .textSelection(.enabled)

                        Spacer()

                        Button("copy") { appState.copyToClipboard(convertedTimestamp) }
                            .buttonStyle(.plain)
                            .font(Theme.monoTiny)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if let error = errorMessage {
                Text(error)
                    .font(Theme.monoTiny)
                    .foregroundStyle(Theme.error)
            }
        }
        .padding(14)
        .onAppear { startTimer() }
        .onDisappear { timerTask?.cancel() }
    }

    // MARK: - Actions

    private func startTimer() {
        timerTask?.cancel()
        timerTask = Task { @MainActor in
            while !Task.isCancelled {
                currentTimestamp = Date().timeIntervalSince1970
                try? await Task.sleep(for: .seconds(1))
            }
        }
    }

    private func convertTimestamp() {
        errorMessage = nil
        convertedDates = []
        guard let ts = TimeInterval(timestampInput) else {
            errorMessage = "Invalid timestamp"
            return
        }
        Task {
            var dates: [String] = []
            for format in TimestampFormat.allCases {
                let dateStr = await appState.toolService.timestampToDate(ts, format: format)
                dates.append("\(format.rawValue): \(dateStr)")
            }
            await MainActor.run { convertedDates = dates }
        }
    }

    private func convertDate() {
        errorMessage = nil
        convertedTimestamp = ""
        Task {
            let result = await appState.toolService.dateToTimestamp(dateInput)
            await MainActor.run {
                switch result {
                case .success(let ts):
                    convertedTimestamp = String(Int(ts))
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
