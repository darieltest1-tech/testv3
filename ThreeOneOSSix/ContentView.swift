import SwiftUI
import UIKit

struct ContentView: View {
    @Environment(\.appLanguage) private var language
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @EnvironmentObject private var patchDraftCoordinator: PatchDraftCoordinator
    @EnvironmentObject private var patchStore: PatchProjectStore
    @EnvironmentObject private var appState: AppState
    @State private var selectedTab: Int = 0
    @State private var filesTabs: FilesTabSession = FilesTabSession()
    @State private var showSettings = false
    @State private var showLogs = false
    @State private var showAppGroupAlert = false
    @StateObject private var scanCoordinator = ScanCoordinator()

    var body: some View {
        Group {
            if horizontalSizeClass == .regular {
                regularLayout
            } else {
                compactLayout
            }
        }
        .tint(AppTheme.accent)
        .imageScale(.small)
        .onChange(of: patchDraftCoordinator.request?.id) { requestID in
            if requestID != nil { selectedTab = 0 }
        }
        .onChange(of: patchDraftCoordinator.importRequest?.id) { requestID in
            if requestID != nil { selectedTab = 0 }
        }
        .onAppear {
#if !targetEnvironment(simulator)
            if SandboxAccess.needsWorseQuery, SandboxAccess.appGroup == nil {
                showAppGroupAlert = true
            }
#endif
        }
        .alert(language.text("appgroup.title"), isPresented: $showAppGroupAlert) {
            Button(language.text("common.ok")) {}
        } message: {
            Text(language.text("appgroup.message"))
        }
        .environmentObject(scanCoordinator)
        .sheet(isPresented: $showSettings) { SettingsView() }
        .sheet(isPresented: $showLogs) { LogView() }
        .sheet(isPresented: $scanCoordinator.isPresented) {
            ScanProgressSheet()
                .environmentObject(scanCoordinator)
                .environment(\.appLanguage, language)
        }
        .overlay(alignment: .bottom) {
            if scanCoordinator.isRunning && !scanCoordinator.isPresented {
                ScanRunningBanner()
                    .environmentObject(scanCoordinator)
                    .environment(\.appLanguage, language)
            }
        }
        .overlay(alignment: .top) {
            if appState.needsUnlock {
                NavigationLink {
                    UnlockView()
                } label: {
                    UnlockBanner()
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.top, 6)
            }
        }
        .patchStorePresentation(patchStore)
    }

    // MARK: - Layouts

    private var compactLayout: some View {
        TabView(selection: $selectedTab) {
            PatchProjectsView(
                onOpenSettings: { showSettings = true },
                onOpenLogs: { showLogs = true }
            )
            .tabItem {
                CompactTabLabel(
                    title: language.text("tab.installed"),
                    systemImage: "bandage.fill"
                )
            }
            .tag(0)

            AppDataBrowserView(
                tabSession: $filesTabs,
                onOpenSettings: { showSettings = true },
                onOpenLogs: { showLogs = true }
            )
            .tabItem {
                CompactTabLabel(
                    title: language.text("tab.files"),
                    systemImage: "folder.fill"
                )
            }
            .tag(1)
        }
    }

    private var regularLayout: some View {
        NavigationSplitView {
            List {
                sidebarRow(title: language.text("tab.installed"), icon: "bandage.fill", tag: 0)
                sidebarRow(title: language.text("tab.files"), icon: "folder.fill", tag: 1)
            }
            .navigationTitle("3106")
            .navigationSplitViewColumnWidth(min: 210, ideal: 240, max: 300)
        } detail: {
            if selectedTab == 0 {
                PatchProjectsView(
                    onOpenSettings: { showSettings = true },
                    onOpenLogs: { showLogs = true }
                )
            } else {
                AppDataBrowserView(
                    tabSession: $filesTabs,
                    onOpenSettings: { showSettings = true },
                    onOpenLogs: { showLogs = true }
                )
            }
        }
        .navigationSplitViewStyle(.balanced)
    }

    private func sidebarRow(title: String, icon: String, tag: Int) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.18)) { selectedTab = tag }
        } label: {
            Label(title, systemImage: icon)
                .fontWeight(selectedTab == tag ? .semibold : .regular)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .listRowBackground(
            selectedTab == tag
                ? AppTheme.accent.opacity(0.14)
                : Color.clear
        )
        .accessibilityAddTraits(selectedTab == tag ? .isSelected : [])
    }
}

// MARK: - Tab label

private struct CompactTabLabel: View {
    let title: String
    let systemImage: String

    @ViewBuilder
    var body: some View {
        if let image = UIImage(
            systemName: systemImage,
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 17, weight: .medium)
        )?.withRenderingMode(.alwaysTemplate) {
            Image(uiImage: image)
        } else {
            Image(systemName: systemImage)
                .font(.system(size: 17, weight: .medium))
        }
        Text(title)
    }
}
