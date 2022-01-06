/// `Key - Value` persistent storage interface
protocol KeyValueStoring {
    /// Set a value for a given key. If value is `nil` &  `key` exists, then this `key - value` pair is removed
    /// from storage. Otherwise `key - value` pair is added if key is not present, or existing value is replaced
    /// with `value`.
    ///
    /// Throws error if writing fails.
    func write<T: Encodable>(value: T?, for key: String) throws

    /// Read value of type `T` for the given `key`. Returns nil if key is not present in the storage.
    func readValue<T: Decodable>(for key: String) throws -> T?
}

extension KeyValueStoring {
    func write<T: Encodable>(
        value: T?,
        for key: String,
        completion: ((Result<Void, Error>) -> Void)?
    ) {
        DispatchQueue.global().async {
            do {
                try write(value: value, for: key)
                completion?(.success(()))
            } catch {
                completion?(.failure(error))
            }
        }
    }
    func readValue<T: Decodable>(
        for key: String,
        queue: DispatchQueue = DispatchQueue.global(),
        completion: @escaping (Result<T?, Error>) -> Void
    ) {
        queue.async {
            do {
                completion(.success(try readValue(for: key)))
            } catch {
                completion(.failure(error))
            }

        }
    }

    // TODO: - Remove legacy
    func getString(for key: String) -> String? {
        try? readValue(for: key)
    }
    func set(string: String?, for key: String) {
        try? write(value: string, for: key)
    }

    func getBool(for key: String) -> Bool? {
        try? readValue(for: key)
    }
    func set(bool: Bool?, for key: String) {
        try? write(value: bool, for: key)
    }
}
