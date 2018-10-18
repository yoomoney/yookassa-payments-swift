import Foundation

final class UserDefaultsStorage {
    let userDefaults: UserDefaults

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
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
    func getString(for key: String) -> String? {
        return userDefaults.string(forKey: key)
    }

    func set(string: String?, for key: String) {
        userDefaults.set(string, forKey: key)
    }

    func getBool(for key: String) -> Bool? {
        return userDefaults.bool(forKey: key)
    }

    func set(bool: Bool?, for key: String) {
        userDefaults.set(bool, forKey: key)
    }
}
