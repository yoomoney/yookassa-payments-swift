enum KeyValueStoringAssembly {

    static var shared: KeyValueStoring?

    static func makeKeychainStorage() -> KeyValueStoring {
        return KeychainStorage(service: Constants.Keys.serviceId)
    }

    static func makeUserDefaultsStorage() -> KeyValueStoring {
        UserDefaultsStorage(userDefaults: UserDefaults.standard)
    }

    static func makeSettingsStorage() -> KeyValueStoring {
        let manager = FileManager.default
        guard
            let url = manager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        else {
            fatalError("failed to initialize settings storage")
        }

        let directory = url.appendingPathComponent("yoo.msdk", isDirectory: true)
        if !manager.fileExists(atPath: directory.path, isDirectory: nil) {
            do {
                try manager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                PrintLogger.error(
                    "failed to create yoo.msdk directory",
                    info: ["error": error.localizedDescription]
                )
            }
        }

        let file = url.appendingPathComponent("settings", isDirectory: false)
        return PlistStorage(storageUrl: file)
    }

    static func makeKeychainStorageMock(testModeSettings: TestModeSettings) -> KeyValueStoring {
        let storage: KeyValueStoring
        if let shared = KeyValueStoringAssembly.shared {
            storage = shared
        } else if testModeSettings.paymentAuthorizationPassed {
            storage = makeAuthorizedKeychainStroageMock()
            shared = storage
        } else {
            storage = KeychainStorageMock()
            shared = storage
        }
        return storage
    }
}

// MARK: - Constants

private extension KeyValueStoringAssembly {
    enum Constants {
        enum Keys {
            static let serviceId = "ru.yoo.kassa.keychainService"
        }
    }
}

private func makeAuthorizedKeychainStroageMock() -> KeychainStorageMock {
    let storage = KeychainStorageMock()
    storage.set(
        string: Constants.Values.moneyCenterAuthToken,
        for: KeyValueStoringKeys.moneyCenterAuthToken
    )
    storage.set(
        string: Constants.Values.walletToken,
        for: KeyValueStoringKeys.walletToken
    )
    storage.set(
        bool: Constants.Values.isReusableWalletToken,
        for: KeyValueStoringKeys.isReusableWalletToken
    )
    return storage
}

private enum Constants {
    enum Values {
        static let moneyCenterAuthToken = "mockMoneyCenterAuthToken"
        static let walletToken = "mockWalletToken"
        static let isReusableWalletToken = true
    }
}
