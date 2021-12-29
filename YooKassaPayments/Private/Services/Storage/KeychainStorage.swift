import Security

final class KeychainStorage {
    // MARK: - Init data

    private let service: String

    // MARK: - Init

    init(service: String) {
        self.service = service
    }
}

extension KeychainStorage {
    func setValue(_ value: String?, for key: String) {
        if let value = value {
            guard let data = value.data(using: .utf8, allowLossyConversion: false) else {
                return
            }
            setValue(data, for: key)
        } else {
            removeValue(for: key)
        }
    }

    func getValue(for key: String) -> String? {
        guard let data = getData(for: key),
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        return string
    }

    func removeValue(for key: String?) {
        var query = makeQuery()
        query[Keys.attributeAccount] = key
        SecItemDelete(query as CFDictionary)
    }

    func removeAll() throws {
        var query = makeQuery()
        query[Keys.matchLimit] = Values.matchLimitAll
        SecItemDelete(query as CFDictionary)
    }

    private func setValue(_ value: Data, for key: String) {
        var query = makeQuery()
        query[Keys.attributeAccount] = key

        if #available(iOS 9.0, *) {
            query[Keys.useAuthenticationUI] = Values.useAuthenticationUIFail
        } else {
            query[Keys.useNoAuthenticationUI] = kCFBooleanTrue
        }

        let status = SecItemCopyMatching(query as CFDictionary, nil)

        switch status {
        case errSecSuccess, errSecInteractionNotAllowed:
            var query = makeQuery()
            query[Keys.attributeAccount] = key

            let attributes = makeAttributes(key: nil, value: value)

            if status == errSecInteractionNotAllowed
            && floor(NSFoundationVersionNumber) <= floor(NSFoundationVersionNumber_iOS_8_0) {
                removeValue(for: key)
                setValue(value, for: key)
            } else {
                SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
            }

        case errSecItemNotFound:
            let attributes = makeAttributes(key: key, value: value)
            SecItemAdd(attributes as CFDictionary, nil)
        default:
            return
        }
    }

    private func getData(for key: String) -> Data? {
        var query = makeQuery()

        query[Keys.matchLimit] = Values.matchLimitOne
        query[Keys.returnData] = kCFBooleanTrue
        query[Keys.attributeAccount] = key

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            return result as? Data
        default:
            return nil
        }
    }

    private func makeQuery() -> [String: Any] {
        var query: [String: Any] = [:]
        query[Keys.secClass] = Values.classGenericPassword
        query[Keys.attributeSynchronizable] = Values.synchronizableAny
        query[Keys.attributeService] = service
        return query
    }

    private func makeAttributes(key: String?, value: Data) -> [String: Any] {
        var attributes: [String: Any]

        if key != nil {
            attributes = makeQuery()
            attributes[Keys.attributeAccount] = key
        } else {
            attributes = [:]
        }

        attributes[Keys.valueData] = value
        attributes[Keys.attributeAccessible] = Values.whenUnlockedThisDeviceOnly
        attributes[Keys.attributeSynchronizable] = kCFBooleanFalse

        return attributes
    }
}

// MARK: - KeyValueStoring

extension KeychainStorage: KeyValueStoring {
    func write<T>(value: T?, for key: String) throws where T: Encodable {
        switch value {
        case let string as String?:
            return setValue(string, for: key)
        case let bool as Bool?:
            switch bool {
            case true?:
                setValue("YES", for: key)
            case false?:
                setValue("NO", for: key)
            case nil:
                removeValue(for: key)
            }
        default:
            PrintLogger.debugWarn("Attempt to write unsuported value")
        }
    }

    func readValue<T>(for key: String) throws -> T? where T: Decodable {
        if T.self == String.self {
            let value = getValue(for: key)
            let casted = value as? T
            return casted
        } else if T.self == Bool.self {
            let value = getValue(for: key).map { ["YES", "1"].contains($0) }
            return value as? T
        }
        PrintLogger.debugWarn("Attempt to read unsuported value type")
        return nil
    }
}

// MARK: - Constants

private extension KeychainStorage {
    enum Keys {
        static let matchLimit = String(kSecMatchLimit)
        static let returnData = String(kSecReturnData)
        static let attributeAccount = String(kSecAttrAccount)
        static let secClass = String(kSecClass)
        static let attributeSynchronizable = String(kSecAttrSynchronizable)
        static let attributeService = String(kSecAttrService)
        static let valueData = String(kSecValueData)
        static let attributeAccessible = String(kSecAttrAccessible)

        @available(iOS 9.0, *)
        static let useAuthenticationUI = String(kSecUseAuthenticationUI)

        @available(iOS, introduced: 8.0, deprecated: 9.0, message: "Use a kSecUseAuthenticationUI instead.")
        static let useNoAuthenticationUI = String(kSecUseNoAuthenticationUI)
    }

    enum Values {
        static let matchLimitOne = kSecMatchLimitOne
        static let matchLimitAll = kSecMatchLimitAll
        static let synchronizableAny = kSecAttrSynchronizableAny
        static let classGenericPassword = String(kSecClassGenericPassword)
        static let whenUnlockedThisDeviceOnly = String(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly)

        @available(iOS 9.0, *)
        static let useAuthenticationUIFail = String(kSecUseAuthenticationUIFail)
    }
}
