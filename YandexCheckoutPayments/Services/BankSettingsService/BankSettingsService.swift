protocol BankSettingsService {
    static var shared: BankSettingsService { get }
    func bankSettings(_ bin: String) -> BankSettings?
}
