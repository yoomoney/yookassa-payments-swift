enum ProcessConfirmation {
    case threeDSecure(String)
    case app2app(String)

    static var allCasesWithNil: [ProcessConfirmation?] = [
        nil,
        .threeDSecure(""),
        .app2app("sberpay://invoicing/v2?redirect_uri="),
    ]
}

extension ProcessConfirmation {
    var description: String {
        let value: String
        switch self {
        case .threeDSecure:
            value = translate(Localized.process3ds)
        case .app2app:
            value = translate(Localized.processApp2App)
        }
        return value
    }

    var url: String {
        let value: String
        switch self {
        case let .threeDSecure(requestUrl):
            value = requestUrl
        case let .app2app(confirmationUrl):
            value = confirmationUrl
        }
        return value
    }

    private enum Localized: String {
        case process3ds = "test_mode.process.3ds"
        case processApp2App = "test_mode.process.app2app"
    }
}

extension ProcessConfirmation: Codable {
    enum CodingKeys: CodingKey {
        case threeDSecure
        case app2app
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try? values.decode(String.self, forKey: .threeDSecure) {
            self = .threeDSecure(value)
        } else if let value = try? values.decode(String.self, forKey: .app2app) {
            self = .app2app(value)
        } else {
            throw DecodingError.dataCorrupted
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .threeDSecure(requestUrl):
            try container.encode(requestUrl, forKey: .threeDSecure)
        case let .app2app(confirmationUrl):
            try container.encode(confirmationUrl, forKey: .app2app)
        }
    }

    enum DecodingError: Error {
        case dataCorrupted
    }
}
