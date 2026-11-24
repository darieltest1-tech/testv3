import Foundation

// Stubs mínimos para tipos referenciados en SecureZIPArchive.
// WallpaperLab fue removido; estos solo permiten que compile.
enum WallpaperLabError: Error {
    case unsupportedPackage
    case symbolicLinkUnsupported
    case packageTooLarge
    case unsafeArchive
    case unknown
}

enum WallpaperLabLimits {
    static let maximumArchiveBytes: Int = 500 * 1024 * 1024
    static let maximumExpandedBytes: Int = 1024 * 1024 * 1024
    static let maximumEntryCount: Int = 10_000
    static let maximumEntryBytes: Int = 500 * 1024 * 1024
    static let maximumPathBytes: Int = 1024
}
