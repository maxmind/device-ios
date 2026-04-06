import MinFraudDevice
import SwiftUI

struct ContentView: View {
    @State private var accountIDText = ""
    @State private var useDefaultServers = true
    @State private var serverURLText = ""
    @State private var loggingEnabled = true
    @State private var autoCollectionEnabled = false

    @State private var tracker: DeviceTracker?

    var body: some View {
        NavigationView {
            if let tracker {
                TrackerView(tracker: tracker, onReset: reset)
            } else {
                ConfigurationView(
                    accountIDText: $accountIDText,
                    useDefaultServers: $useDefaultServers,
                    serverURLText: $serverURLText,
                    loggingEnabled: $loggingEnabled,
                    autoCollectionEnabled: $autoCollectionEnabled,
                    onInitialize: { tracker in
                        self.tracker = tracker
                    }
                )
            }
        }
        .navigationViewStyle(.stack)
    }

    private func reset() {
        tracker?.shutdown()
        tracker = nil
    }
}

struct ConfigurationView: View {
    @Binding var accountIDText: String
    @Binding var useDefaultServers: Bool
    @Binding var serverURLText: String
    @Binding var loggingEnabled: Bool
    @Binding var autoCollectionEnabled: Bool

    var onInitialize: (DeviceTracker) -> Void

    private var canInitialize: Bool {
        guard let accountID = Int(accountIDText), accountID > 0 else { return false }
        if !useDefaultServers {
            guard URL(string: serverURLText) != nil, !serverURLText.isEmpty else { return false }
        }
        return true
    }

    var body: some View {
        Form {
            Section("Configuration") {
                HStack {
                    Text("MaxMind account ID")
                    TextField("Required", text: $accountIDText)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                }

                Toggle("Use default servers", isOn: $useDefaultServers)

                if !useDefaultServers {
                    HStack {
                        Text("Custom server URL")
                        TextField("https://example.com", text: $serverURLText)
                            .keyboardType(.URL)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .multilineTextAlignment(.trailing)
                    }
                }

                Toggle("Enable logging", isOn: $loggingEnabled)
                Toggle("Auto-collect (5 min)", isOn: $autoCollectionEnabled)
            }

            Section {
                Button("Initialize") {
                    initialize()
                }
                .disabled(!canInitialize)
            }
        }
        .navigationTitle("MinFraud Device SDK")
    }

    private func initialize() {
        guard let accountID = Int(accountIDText), accountID > 0 else { return }

        let serverURL: URL? = useDefaultServers ? nil : URL(string: serverURLText)

        let config = SDKConfig(
            accountID: accountID,
            serverURL: serverURL,
            loggingEnabled: loggingEnabled,
            collectionIntervalSeconds: autoCollectionEnabled ? 300 : 0
        )
        onInitialize(DeviceTracker(config: config))
    }
}

struct TrackerView: View {
    let tracker: DeviceTracker
    let onReset: () -> Void

    @State private var logEntries: [String] = []
    @State private var isSending = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Button("Send Device Data") {
                    Task {
                        await sendDeviceData()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isSending)

                Button("Clear Log") {
                    logEntries.removeAll()
                }
                .buttonStyle(.bordered)

                Button("Reset") {
                    onReset()
                }
                .buttonStyle(.bordered)
            }
            .padding()

            Divider()

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 4) {
                        ForEach(Array(logEntries.enumerated()), id: \.offset) { index, entry in
                            Text(entry)
                                .font(.system(.caption, design: .monospaced))
                                .id(index)
                        }
                    }
                    .padding(.horizontal)
                }
                .onChange(of: logEntries.count) { _ in
                    if let last = logEntries.indices.last {
                        proxy.scrollTo(last, anchor: .bottom)
                    }
                }
            }
        }
        .navigationTitle("MinFraud Device SDK")
        .onAppear {
            log("DeviceTracker initialized")
        }
    }

    private func log(_ message: String) {
        let timestamp = DateFormatter.logFormatter.string(from: Date())
        logEntries.append("[\(timestamp)] \(message)")
    }

    private func sendDeviceData() async {
        isSending = true
        defer { isSending = false }

        log("Sending device data...")
        do {
            let result = try await tracker.collectAndSend()
            log("Success — tracking token: \(result.trackingToken)")
        } catch {
            log("Error: \(error.localizedDescription)")
        }
    }
}

private extension DateFormatter {
    static let logFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
}
