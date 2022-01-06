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
    func write<T>(value: T?, for key: String) throws where T: Encodable {
        userDefaults.setValue(value, forKey: key)
    }

    func readValue<T>(for key: String) throws -> T? where T: Decodable {
        userDefaults.value(forKey: key) as? T
    }
}
