import Foundation

enum TermsOfServiceFactory {
    static func makeTermsOfService() -> TermsOfService {
        return TermsOfService(text: §Localized.TermsOfService.text,
                              hyperlink: §Localized.TermsOfService.hyperlink,
                              url: Constants.termsOfServiceUrl)
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
    static let termsOfServiceUrl = URL(string: "https://money.yandex.ru/page?id=526623")!
}
