import Foundation

final class BankServiceSettingsImpl {
    static var shared: BankSettingsService {
        return _shared
    }

    private static let _shared = BankServiceSettingsImpl()

    private let queue = DispatchQueue(
        label: "ru.yandex.mobile.money.YandexCheckoutPayments.BankSettingsService",
        qos: .userInteractive
    )

    // MARK: - Initialization

    init() {
        loadBankSettingsIfNeeded()
    }

    // MARK: - Data

    private var bankBins: [String: BankSettings] = [:]
}

// MARK: - BankSettingsService

extension BankServiceSettingsImpl: BankSettingsService {
    func bankSettings(_ bin: String) -> BankSettings? {
        var bin = bin
        if bin.count > 6 {
            bin = String(bin[..<bin.index(bin.startIndex, offsetBy: 6)])
        }
        return bankBins[bin]
    }
}

// MARK: - Private scope

private extension BankServiceSettingsImpl {
    func loadBankSettingsIfNeeded() {
        queue.async {
            guard self.bankBins.isEmpty else { return }
            guard let path = Bundle.framework.path(forResource: "banks", ofType: "json"),
                  let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
                  let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any],
                  let banks = json["banks"] as? [[String: Any]] else {
                assertionFailure("banks.json not found or not parsed")
                return
            }
            banks.forEach {
                guard let logos = $0["logo"] as? [String: Any],
                      let listLogoName = logos["list"] as? String,
                      let bins = $0["bins"] as? [String] else {
                    return
                }
                let bankSettings = BankSettings(logoName: listLogoName)
                bins.forEach { self.bankBins[$0] = bankSettings }
            }
        }
    }
}
