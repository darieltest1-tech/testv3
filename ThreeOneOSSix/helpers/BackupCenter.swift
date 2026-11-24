import Foundation

// Stub mínimo: BackupCenter fue removido del proyecto.
// Se mantiene la API pública para compatibilidad de compilación con
// FileBrowserView, FileInfoView, FileManagerService y FileReplacementService.
final class BackupCenter {
    static let shared = BackupCenter()
    private init() {}

    enum Feature { case file, folder }

    struct BackupRecord {
        let byteCount: Int64
    }

    @discardableResult
    func createVersionSnapshot(
        target: URL,
        feature: Feature = .file,
        reason: String = "",
        containerPath: String? = nil,
        bundleID: String? = nil
    ) throws -> Void {
        // No-op: backup system removed
    }

    @discardableResult
    func manualBackup(
        target: URL,
        feature: Feature = .file,
        label: String = "",
        containerPath: String? = nil,
        bundleID: String? = nil
    ) throws -> BackupRecord {
        // No-op: backup system removed
        return BackupRecord(byteCount: 0)
    }
}
