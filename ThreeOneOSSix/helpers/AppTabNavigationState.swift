import Foundation

// Secciones simplificadas: solo Patches y App Data
enum AppSection: Int, CaseIterable, Identifiable {
    case installed = 0
    case files = 1

    var id: Int { rawValue }
}

extension AppSection {
    var titleKey: String {
        switch self {
        case .installed: return "tab.installed"
        case .files:     return "tab.files"
        }
    }

    var systemImage: String {
        switch self {
        case .installed: return "bandage.fill"
        case .files:     return "folder.fill"
        }
    }
}

// MARK: - FileBrowserDestination

struct FileBrowserDestination: Hashable {
    let containerPath: String
    let startPath: String
    let title: String
    let bundleID: String?
    let readOnly: Bool

    init(
        containerPath: String,
        startPath: String,
        title: String,
        bundleID: String?,
        readOnly: Bool = false
    ) {
        self.containerPath = containerPath
        self.startPath = startPath
        self.title = title
        self.bundleID = bundleID
        self.readOnly = readOnly
    }
}

// MARK: - FilesTabState

struct FilesTabState: Identifiable, Equatable {
    let id: UUID
    var customTitle: String?
    var navigationPath: [FileBrowserDestination]

    func displayTitle(defaultTitle: String) -> String {
        customTitle ?? navigationPath.last?.title ?? defaultTitle
    }

    var currentPath: String? {
        navigationPath.last?.startPath
    }
}

// MARK: - FilesTabSession

struct FilesTabSession: Equatable {
    private(set) var tabs: [FilesTabState]
    private(set) var selectedTabID: UUID

    init(initialTabID: UUID = UUID()) {
        tabs = [FilesTabState(id: initialTabID, customTitle: nil, navigationPath: [])]
        selectedTabID = initialTabID
    }

    var activeTab: FilesTabState? {
        tabs.first { $0.id == selectedTabID }
    }

    func navigationPath(for id: UUID) -> [FileBrowserDestination] {
        tabs.first { $0.id == id }?.navigationPath ?? []
    }

    mutating func setNavigationPath(_ path: [FileBrowserDestination], for id: UUID) {
        guard let index = tabs.firstIndex(where: { $0.id == id }) else { return }
        tabs[index].navigationPath = path
    }

    mutating func setActiveNavigationPath(_ path: [FileBrowserDestination]) {
        setNavigationPath(path, for: selectedTabID)
    }

    mutating func openTab(id: UUID = UUID(), navigationPath: [FileBrowserDestination] = []) {
        tabs.append(FilesTabState(id: id, customTitle: nil, navigationPath: navigationPath))
        selectedTabID = id
    }

    mutating func selectTab(_ id: UUID) {
        guard tabs.contains(where: { $0.id == id }) else { return }
        selectedTabID = id
    }

    mutating func renameTab(_ id: UUID, to name: String) {
        guard let index = tabs.firstIndex(where: { $0.id == id }) else { return }
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        tabs[index].customTitle = trimmed.isEmpty ? nil : trimmed
    }

    mutating func closeTab(_ id: UUID, replacementID: UUID = UUID()) {
        guard let index = tabs.firstIndex(where: { $0.id == id }) else { return }
        if tabs.count == 1 {
            tabs = [FilesTabState(id: replacementID, customTitle: nil, navigationPath: [])]
            selectedTabID = replacementID
            return
        }
        tabs.remove(at: index)
        if selectedTabID == id {
            selectedTabID = tabs[min(index, tabs.count - 1)].id
        }
    }

    mutating func closeOtherTabs(keeping id: UUID) {
        guard let keptTab = tabs.first(where: { $0.id == id }) else { return }
        tabs = [keptTab]
        selectedTabID = id
    }
}

// MARK: - WallpaperFeatureSupportPolicy (mantenida por compatibilidad interna)
enum WallpaperFeatureSupportPolicy {
    static func isSupported(major: Int) -> Bool { false }
}
