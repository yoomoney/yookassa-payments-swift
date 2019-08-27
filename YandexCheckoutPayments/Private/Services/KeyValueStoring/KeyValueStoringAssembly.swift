enum KeyValueStoringAssembly {

    static weak var shared: KeyValueStoring?

    static func makeKeychainStorage() -> KeyValueStoring {
        return KeychainStorage(service: Constants.Keys.serviceId)
    }

    static func makeSettingsStorage() -> KeyValueStoring {
        return UserDefaultsStorage(userDefaults: .standard)
    }

    static func makeMockKeychainStorage(testModeSettings: TestModeSettings) -> KeyValueStoring {
        let storage: KeyValueStoring
        if let shared = KeyValueStoringAssembly.shared {
            storage = shared
        } else if testModeSettings.paymentAuthorizationPassed {
            storage = makeAuthorizedMockKeychainStroage()
            shared = storage
        } else {
            storage = MockKeychainStorage()
            shared = storage
        }
        return storage
    }
}

// MARK: - Constants
private extension KeyValueStoringAssembly {
    enum Constants {
        enum Keys {
            static let serviceId = "yandex.money.msdk2.keychainService"
        }
    }
}

private func makeAuthorizedMockKeychainStroage() -> MockKeychainStorage {
    let storage = MockKeychainStorage()
    storage.set(string: Constants.Values.yandexToken, for: Constants.Keys.yandexToken)
    storage.set(string: Constants.Values.yamoneyToken, for: Constants.Keys.yamoneyToken)
    storage.set(bool: Constants.Values.isReusableYamoneyToken, for: Constants.Keys.isReusableYamoneyToken)
    return storage
}

private enum Constants {
    enum Keys {
        static let yandexToken = "yandexToken"
        static let yamoneyToken = "yamoneyToken"
        static let isReusableYamoneyToken = "isReusableYamoneyToken"
    }
    enum Values {
        static let yandexToken = "mockYandexToken"
        static let yamoneyToken = "mockYamoneyToken"
        static let isReusableYamoneyToken = true
    }
}
