final class DevHostService {
    let storage: KeyValueStoring

    init(storage: KeyValueStoring) {
        self.storage = storage
    }

    subscript(key: Key<String>) -> String {
        get {
            return storage.getString(for: key.name) ?? ""
        }
        set {
            storage.setAny(key.name, for: newValue)
        }
    }

    subscript(key: Key<Bool>) -> Bool {
        get {
            return storage.getInt(for: key.name) == 1
        }
        set {
            storage.setInt(newValue ? 1 : 0, for: key.name)
        }
    }

    struct Key<T> {
        let name: String
    }

    enum Keys {
        static let merchantKey = Key<String>(name: "merchant_key_preference")
        static let devHosKey = Key<Bool>(name: "dev_host_preference")
    }
}
