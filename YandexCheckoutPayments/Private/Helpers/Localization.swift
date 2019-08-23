import Foundation

prefix operator §

prefix func §<T: RawRepresentable>(_ key: T) -> String
    where T.RawValue == String {
    return NSLocalizedString(key.rawValue, bundle: Bundle.framework, comment: key.rawValue)
}

enum CommonLocalized: String {
    enum Error: String {
        case unknown = "Common.Error.unknown"
    }

    case ok = "Common.button.ok"
    case cancel = "Common.button.cancel"
}
