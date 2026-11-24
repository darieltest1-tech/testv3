import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appLanguage) private var language
    @EnvironmentObject private var appState: AppState
    @AppStorage(AppLanguage.storageKey) private var languageCode = AppLanguage.english.rawValue
    @AppStorage("sound.effects.enabled") private var soundEffectsEnabled = true

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 14) {
                        AppLogo()
                        VStack(alignment: .leading, spacing: 3) {
                            Text("3106").font(.headline)
                            Text(language.text("common.version", appVersion))
                                .font(.subheadline).foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section(language.text("settings.language")) {
                    Picker(language.text("settings.language"), selection: $languageCode) {
                        ForEach(AppLanguage.allCases) { option in
                            Text(option.displayName).tag(option.rawValue)
                        }
                    }
                    .pickerStyle(.inline)
                }

                Section {
                    NavigationLink {
                        AcknowledgementsView()
                    } label: {
                        Label(language.text("ack.title"), systemImage: "heart.text.square.fill")
                    }
                    RespringButton()
                } header: {
                    Text(language.text("settings.backup"))
                }

                Section {
                    Toggle(isOn: $soundEffectsEnabled) {
                        Label(language.text("settings.sound_effects"), systemImage: "speaker.wave.2")
                    }
                    Toggle(isOn: Binding(
                        get: { StoreIconFallbackService.isEnabled },
                        set: { StoreIconFallbackService.setEnabled($0) }
                    )) {
                        Label(language.text("settings.storeicon_fallback"), systemImage: "network")
                    }
                } header: {
                    Text(language.text("settings.sound_effects"))
                } footer: {
                    Text(language.text("settings.sound_effects_footer"))
                }

                Section(language.text("common.device")) {
                    LabeledContent(language.text("dashboard.hardware_model"), value: AppInfo.displayMachineName)
                    LabeledContent(language.text("settings.ios_version"), value: "\(AppInfo.osVersion) (\(AppInfo.osBuild))")
                    LabeledContent(language.text("settings.access_backend"), value: SandboxAccess.backend.displayName)
                    LabeledContent(language.text("settings.app_group"), value: appGroupStatus)
                    NavigationLink {
                        SandboxDiagnosticsView()
                    } label: {
                        Label(language.text("sandbox.diag.title"), systemImage: "stethoscope")
                    }
                }

                Section {
                    HStack {
                        Text(language.text("settings.current_version"))
                        Spacer()
                        Text(language.text(appState.isSupported ? "settings.supported" : "settings.unsupported"))
                            .foregroundStyle(appState.isSupported ? Color.green : Color.red)
                    }
                    LabeledContent("iOS 17", value: ExploitSupportPolicy.verifiedIOS17Range)
                    LabeledContent("iOS 18", value: ExploitSupportPolicy.verifiedIOS18Range)
                    LabeledContent("iOS 26", value: "\(ExploitSupportPolicy.verifiedIOS26BadQueryRange) · \(ExploitSupportPolicy.verifiedIOS26WorseQueryRange)")
                    LabeledContent("iOS 27", value: ExploitSupportPolicy.verifiedIOS27Range)
                    LabeledContent("iOS 27.3", value: "\(ExploitSupportPolicy.verifiedIOS27BuildGatedRange) · \(ExploitSupportPolicy.verifiedIOS27Builds.joined(separator: ", "))")
                    if let reason = appState.unsupportedMessage {
                        Text(reason).font(.footnote).foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                } header: {
                    Text(language.text("settings.verified_versions"))
                } footer: {
                    Text(language.text("settings.supported_versions_footer"))
                }

                Section(language.text("settings.github")) {
                    if let destination = URL(string: "https://github.com/QuinnTang74/3106.git") {
                        Link(destination: destination) {
                            HStack(spacing: 12) {
                                Label("GitHub", systemImage: "link")
                                Spacer()
                                Text("QuinnTang74/3106").font(.caption).foregroundStyle(.secondary)
                            }
                            .contentShape(Rectangle())
                        }
                    }
                }
            }
            .tint(AppTheme.accent)
            .navigationTitle(language.text("settings.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(language.text("common.done")) { dismiss() }.fontWeight(.semibold)
                }
            }
        }
    }

    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }

    private var appGroupStatus: String {
        guard SandboxAccess.needsWorseQuery else { return "—" }
        return SandboxAccess.appGroup ?? language.text("settings.app_group_missing")
    }
}
