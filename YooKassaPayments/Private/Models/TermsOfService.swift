enum TermsOfServiceFactory {
    static func makeTermsOfService() -> TermsOfService {
        return TermsOfService(
            text: Localized.TermsOfService.text,
            hyperlink: Localized.TermsOfService.hyperlink,
            url: Constants.termsOfServiceUrl
        )
    }
}

struct TermsOfService {
    let text: String
    let hyperlink: String
    let url: URL
}

// MARK: - Localized

private enum Localized {
    enum TermsOfService {
        static let text = NSLocalizedString(
            "TermsOfService.Text",
            bundle: Bundle.framework,
            value: "Нажимая кнопку, вы принимаете",
            comment: "Текст `Нажимая кнопку, вы принимаете` https://yadi.sk/i/Z2oi1Uun7nS-jA"
        )
        static let hyperlink = NSLocalizedString(
            "TermsOfService.Hyperlink",
            bundle: Bundle.framework,
            value: "условия сервиса",
            comment: "Текст `условия сервиса` https://yadi.sk/i/Z2oi1Uun7nS-jA"
        )
    }
}

// MARK: - Constants

private enum Constants {
    // swiftlint:disable force_unwrapping
    static let termsOfServiceUrl = URL(string: "https://yoomoney.ru/page?id=526623")!
    // swiftlint:enable force_unwrapping
}
