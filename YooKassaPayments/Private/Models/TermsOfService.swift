enum TermsOfServiceFactory {
    static func makeTermsOfService() -> TermsOfService {
        return TermsOfService(
            text: §Localized.TermsOfService.text,
            hyperlink: §Localized.TermsOfService.hyperlink,
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
    enum TermsOfService: String {
        case text = "TermsOfService.Text"
        case hyperlink = "TermsOfService.Hyperlink"
    }
}

// MARK: - Constants

private enum Constants {
    // swiftlint:disable force_unwrapping
    static let termsOfServiceUrl = URL(string: "https://yoomoney.ru/page?id=526623")!
    // swiftlint:enable force_unwrapping
}
