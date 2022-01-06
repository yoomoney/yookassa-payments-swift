final class KeychainStorageMock {
    let writeQueue = DispatchQueue(label: "com.msdk.KeychainStorageMock.writeQueue")
    private var data: [String: Any] = [:]
}

// MARK: - KeyValueStoring

extension KeychainStorageMock: KeyValueStoring {
    func readValue<T>(for key: String) throws -> T? where T: Decodable {
        data[key] as? T
    }

    func write<T>(value: T?, for key: String) throws where T: Encodable {
        data[key] = value
    }
}
