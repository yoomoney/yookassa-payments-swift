protocol KeyValueStoring: class {
    func getString(for key: String) -> String?
    func set(string: String?, for key: String)

    func getBool(for key: String) -> Bool?
    func set(bool: Bool?, for key: String)
}
