final class KeychainStorageMock {
    private var data: [String: Any] = [:]
}

// MARK: - KeyValueStoring

extension KeychainStorageMock: KeyValueStoring {
    func getString(for key: String) -> String? {
        guard let value = data[key] as? String else {
            return nil
        }
        return value
    }

    func set(string: String?, for key: String) {
        data[key] = string
    }

    func getBool(for key: String) -> Bool? {
        guard let value = data[key] as? Bool else {
            return nil
        }
        return value
    }

    func set(bool: Bool?, for key: String) {
        data[key] = bool
    }
}
