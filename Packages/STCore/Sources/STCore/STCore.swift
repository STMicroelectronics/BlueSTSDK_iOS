import Foundation

public struct STCore {
    public static let appVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1.0"
    public static let appShortVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    public static let catalogVersion = Bundle.main.infoDictionary?["CFBundleCatalogVersionString"] as? String ?? "5.2.0"
}
