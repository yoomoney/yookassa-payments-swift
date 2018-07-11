import Foundation

/// Services to identify their countries to information about them
class IdentifyCountryService {

    /// The maximum length of the country code.
    /// Immutable value. Is 4.
    let countryCodeMaxLength = Constants.countryCodeMaxLength

    init() {  }

    fileprivate let countryCodes = Static.countryCodes

    func countryCode(from string: String, countryMaxLength: Int) -> String? {
        guard let codes = countryCodes else { return nil }

        var codeCountry: String?
        let start = string.count >= countryMaxLength ? countryMaxLength : string.count

        for i in stride(from: start, to: 0, by: -1) {
            let index = string.index(string.startIndex, offsetBy: i)
            let prefix = String(string[..<index])

            if codes.contains(prefix) {
                codeCountry = prefix
                break
            }
        }
        return codeCountry
    }
}

// MARK: - Private
fileprivate extension IdentifyCountryService {
    struct Static {
        static let countryCodes: Set<String>? = {
            guard let filePath = Bundle.framework.path(forResource: "CountryCode", ofType: "json") else {
                assertionFailure("File path for resource CountryCode.json unavailable")
                return nil
            }
            let url = URL(fileURLWithPath: filePath)
            guard let data = try? Data(contentsOf: url),
                  let json = (try? JSONSerialization.jsonObject(with: data)) as? [String] else { return nil }
            return Set(json)
        }()
    }
}

// MARK: - Constants
private extension IdentifyCountryService {
    enum Constants {
        static let countryCodeMaxLength = 4
    }
}
