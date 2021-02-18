enum BankSettingsServiceAssembly {
    static func makeService() -> BankSettingsService {
        BankServiceSettingsImpl()
    }
}

final class BankServiceSettingsImpl {
    static var shared: BankSettingsService {
        return _shared
    }

    private static let _shared = BankServiceSettingsImpl()

    private let queue = DispatchQueue(
        label: "ru.yookassa.payments.queue.BankSettingsService",
        qos: .userInteractive
    )

    // MARK: - Init

    init() {
        loadBankSettingsIfNeeded()
    }

    // MARK: - Properties

    private var bankBins: [String: BankSettings] = [:]
}

// MARK: - BankSettingsService

extension BankServiceSettingsImpl: BankSettingsService {
    func bankSettings(
        _ cardMask: String
    ) -> BankSettings? {
        var bin = makePanFromCardMask(cardMask)
        if bin.count > 6 {
            bin = String(bin[..<bin.index(bin.startIndex, offsetBy: 6)])
        }
        return bankBins[bin]
    }

    private func makePanFromCardMask(
        _ cardMask: String
    ) -> String {
        let endIndex = cardMask.index(cardMask.startIndex, offsetBy: 6, limitedBy: cardMask.endIndex)
            ?? cardMask.index(cardMask.startIndex, offsetBy: cardMask.count, limitedBy: cardMask.endIndex)
            ?? cardMask.startIndex

        let charsWithoutDecimals = cardMask
            .components(separatedBy: CharacterSet.decimalDigits)
            .joined()
        let charsWithoutDecimalsSet = CharacterSet(charactersIn: charsWithoutDecimals)
        return (cardMask[cardMask.startIndex..<endIndex])
            .components(separatedBy: charsWithoutDecimalsSet)
            .joined()
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
