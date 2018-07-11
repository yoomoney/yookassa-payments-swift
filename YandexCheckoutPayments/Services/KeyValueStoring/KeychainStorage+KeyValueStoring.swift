extension KeychainStorage: KeyValueStoring {

    func getString(for key: String) -> String? {
        return getValue(for: key)
    }

    func set(string: String?, for key: String) {
        setValue(string, for: key)
    }

    func getBool(for key: String) -> Bool? {
        guard let value = getValue(for: key) else { return nil }
        return ["YES", "1"].contains(value)
    }

    func set(bool: Bool?, for key: String) {
        switch bool {
        case true?:
            setValue("YES", for: key)
        case false?:
            setValue("NO", for: key)
        case nil:
            removeValue(for: key)
        }
    }
}
