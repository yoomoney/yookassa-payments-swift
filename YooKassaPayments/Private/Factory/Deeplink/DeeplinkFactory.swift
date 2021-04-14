import Foundation

enum DeepLinkFactory {
    
    enum YooMoney {
        static let host = "yoomoney"
        enum exchange {
            static let firstPath = "exchange"
            static let cryptogram = "cryptogram"
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    static func makeDeepLink(url: URL) -> DeepLink? {
        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let host = components.host
        else { return nil }

        let firstPathComponent = components.path
            .split(separator: "/")
            .filter { !$0.isEmpty }
            .map(String.init)
            .first

        let query = components
            .queryItems?
            .map { ($0.name, $0.value) }
            .reduce(into: [:]) { $0[$1.0] = $1.1 }
            ?? [:]

        let action = components.fragment

        let deepLink: DeepLink?

        switch (host, firstPathComponent, query, action) {
        case (YooMoney.host, YooMoney.exchange.firstPath, query, _):
            guard let cryptogram = query["cryptogram"],
                  !cryptogram.isEmpty else {
                deepLink = nil
                break
            }
            deepLink = .yooMoneyExchange(cryptogram: cryptogram)
        
        default:
            deepLink = nil
        }

        return deepLink
    }
}
