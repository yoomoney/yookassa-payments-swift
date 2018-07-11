import Foundation

func translate<T: RawRepresentable>(_ key: T) -> String
    where T.RawValue == String {
    return NSLocalizedString(key.rawValue, comment: key.rawValue)
}

enum CommonLocalized: String {
    case save = "common.save"
    case none = "common.none"
    case on = "common.on"
    case off = "common.off"
}
