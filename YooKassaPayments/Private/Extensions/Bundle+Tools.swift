extension Bundle {
    static var framework: Bundle {
        class Class {}
        return Bundle(for: Class.self)
    }

    static var frameworkVersion: String {
        Bundle.framework.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
}
