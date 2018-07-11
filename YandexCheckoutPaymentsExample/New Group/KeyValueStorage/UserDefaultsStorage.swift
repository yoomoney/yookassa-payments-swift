import Foundation

class UserDefaultsStorage {

    // MARK: - Private properties

    private let userDefaults: UserDefaults

    // MARK: - Initialization/Deinitialization

    init(userDefault: UserDefaults) {
        self.userDefaults = userDefault
        userDefaults.synchronize()
        subscribeForUserDefaultsDidChange()
    }

    deinit {
        unsubscribeForAllNotifications()
    }

    private func subscribeForUserDefaultsDidChange() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(userDefaultsDidChange),
                                               name: UserDefaults.didChangeNotification,
                                               object: nil)
    }

    private func unsubscribeForAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc
    private func userDefaultsDidChange() {
        userDefaults.synchronize()
    }
}

extension UserDefaultsStorage: KeyValueStoring {

    func getAny(for key: String) -> Any? {
        return userDefaults.object(forKey: key)
    }

    func setAny(_ value: Any?, for key: String) {
        userDefaults.set(value, forKey: key)
    }

    func getBool(for key: String) -> Bool? {
        return userDefaults.object(forKey: key) as? Bool
    }

    func setBool(_ value: Bool?, for key: String) {
        userDefaults.set(value, forKey: key)
    }

    func getInt(for key: String) -> Int? {
        return userDefaults.object(forKey: key) as? Int
    }

    func setInt(_ value: Int?, for key: String) {
        userDefaults.set(value, forKey: key)
    }

    func getString(for key: String) -> String? {
        return userDefaults.object(forKey: key) as? String
    }

    func setString(_ value: String?, for key: String) {
        userDefaults.set(value, forKey: key)
    }

    func getDecimal(for key: String) -> Decimal? {
        guard let stringValue = userDefaults.object(forKey: key) as? String else {
            return nil
        }

        return Decimal(string: stringValue, locale: Locale(identifier: "ru_RU"))
    }

    func setDecimal(_ value: Decimal?, for key: String) {
        if var decimal = value {
            let stringValue = NSDecimalString(&decimal, Locale(identifier: "ru_RU"))
            userDefaults.set(stringValue, forKey: key)
        } else {
            userDefaults.set(nil, forKey: key)
        }
    }
}
