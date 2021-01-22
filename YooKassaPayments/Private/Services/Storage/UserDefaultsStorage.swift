final class UserDefaultsStorage {

    // MARK: - Init data

    let userDefaults: UserDefaults

    // MARK: - Init

    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    // MARK: - Deinit

    deinit {
        unsubscribeForAllNotifications()
    }
}

extension UserDefaultsStorage {
    private func subscribeForUserDefaultsDidChange() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDefaultsDidChange),
            name: UserDefaults.didChangeNotification,
            object: nil
        )
    }

    private func unsubscribeForAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc
    private func userDefaultsDidChange() {
        userDefaults.synchronize()
    }
}

// MARK: - KeyValueStoring

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
