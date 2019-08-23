import Foundation

/// Formats a string of digits in phone number.
class PhoneNumberFormatter: NSObject {

    /// Phone identify mode.
    enum CountryIdentifyMode {

        /// Manual identify mode.
        /// In this mode, the country code is specified in the mask.
        case manual

        /// Automatic identify mode.
        /// In this mode, the country code is automatically detected.
        case automatic(identifyService: IdentifyCountryService)
    }

    /// The maximum length of the phone, the constant is equal to 10.
    let phoneMaxLength = Constants.phoneMaxLength

    /// The length of the country code is automatically detected.
    fileprivate(set) var countryCodeLength = 0

    /// Phone number formatter.
    ///
    /// - important: The plus '+' symbol appended to the beginning automatically in automatic identify mode.
    ///
    /// - parameter countryIdentifyMode: instance of IdentifyCountryService class.
    ///
    /// - parameter phoneMask: You can specify a custom format mask for phone numbers.
    /// In automatic mode, the country code is always at the beginning.
    /// If the parameter is not set, accept the default values:
    /// for identify mode manual: '+7 (XXX) XXX-XX-XX'
    /// for identify mode automatic: ' (XXX) XXX-XX-XX'
    ///
    /// - returns: Instance of PhoneNumberFormatter.
    init(countryIdentifyMode: CountryIdentifyMode, phoneMask: String? = nil) {
        self.countryIdentifyMode = countryIdentifyMode

        if let phoneMask = phoneMask, phoneMask.isEmpty == false {
            self.phoneMask = phoneMask
        } else {
            switch countryIdentifyMode {
            case .automatic(identifyService: let service):
                self.phoneMask = " " + Constants.defaultPhoneMask
                self.countryCodeLength = service.countryCodeMaxLength
            case .manual:
                self.phoneMask = "+7 " + Constants.defaultPhoneMask
                self.countryCodeLength = 1
            }
        }
    }

    /// Adds a format for phone number.
    ///
    /// - parameter phone: Phone number.
    ///
    /// - returns: The formatted phone number
    @discardableResult
    func format(phone: String) -> String {
        let trimmedPhone = phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()

        switch countryIdentifyMode {
        case .automatic(identifyService: let service):
            return format(phone: trimmedPhone, identifyService: service, phoneMask: phoneMask)

        case .manual:
            return format(phone: trimmedPhone, phoneMask: phoneMask)
        }
    }

    /// Check whether a string is a telephone number.
    ///
    /// - parameter string: The alleged phone number.
    ///
    /// - returns:
    func isPhone(string: String) -> Bool {
        let containSpecificChars = string.rangeOfCharacter(from: phoneNumberValidation.inverted) == nil

        let secondIndex = string.index(string.startIndex, offsetBy: 1, limitedBy: string.endIndex) ?? string.startIndex
        let range = string.startIndex..<secondIndex
        let firstIsSpecific = string.rangeOfCharacter(from: phoneNumberValidation, options: [], range: range) != nil

        return containSpecificChars || firstIsSpecific
    }

    // MARK: - Private properties
    fileprivate let countryIdentifyMode: CountryIdentifyMode
    fileprivate let phoneMask: String

    fileprivate lazy var phoneNumberValidation: CharacterSet = {
        var set = CharacterSet.controlCharacters
        set = set.union(CharacterSet.decimalDigits)

        let maskSymbols = self.phoneMask.components(separatedBy: self.phonedMaskSpecialSymbols).joined()
        set.insert(charactersIn: "+" + maskSymbols)
        return set
    }()

    fileprivate let phonedMaskSpecialSymbols: CharacterSet = {
        var set = CharacterSet.decimalDigits
        set.insert(charactersIn: Constants.specifyFormatSymbol)
        return set
    }()

    fileprivate let decimalsWithPlus: CharacterSet = {
        var set = CharacterSet.decimalDigits
        set.insert(charactersIn: "+")
        return set
    }()
}

// MARK: - Private
private extension PhoneNumberFormatter {
    func format(phone: String, identifyService: IdentifyCountryService, phoneMask: String) -> String {
        guard let countryCode
            = identifyService.countryCode(from: phone,
                                          countryMaxLength: identifyService.countryCodeMaxLength) else {

            if phone.count >= identifyService.countryCodeMaxLength {
                let index = phone.index(phone.startIndex, offsetBy: identifyService.countryCodeMaxLength)
                return String(phone[..<index])
            } else {
                return phone
            }
        }

        let phoneMask = "+" + countryCode.map { _ in Constants.specifyFormatSymbol }.joined() + phoneMask
        return format(phone: phone, phoneMask: phoneMask)
    }

    func format(phone: String, phoneMask: String) -> String {
        updateCountryCodeLength(phoneMask: phoneMask)

        let trimmingString = phoneMask.components(separatedBy: decimalsWithPlus.inverted).joined()
        let trimmingSet = CharacterSet(charactersIn: trimmingString)
        let trimmedMask = phoneMask.trimmingCharacters(in: trimmingSet)
        let decimalsInMask = phoneMask.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()

        var result = phone.isEmpty ? "" : trimmingString
        var newPhone = phone

        let distanceToSubstring = decimalsInMask.count
        let isOnlyMaskInPhone = phone.commonPrefix(with: decimalsInMask).isEmpty == false
        let indexToSubstring = phone.index(phone.startIndex, offsetBy: distanceToSubstring, limitedBy: phone.endIndex)
        if let indexToSubstring = indexToSubstring, isOnlyMaskInPhone {
            newPhone = String(phone[indexToSubstring...])
        }

        var index = newPhone.startIndex
        for currentCharacter in trimmedMask {
            guard index != newPhone.endIndex else { break }

            if currentCharacter == Character(Constants.specifyFormatSymbol) {
                result.append(newPhone[index])
                index = newPhone.index(after: index)
            } else {
                result.append(currentCharacter)
            }
        }
        return result
    }

    func updateCountryCodeLength(phoneMask: String) {
        let trimmedMask = phoneMask.components(separatedBy: phonedMaskSpecialSymbols.inverted).joined()
        if let maskIndex = trimmedMask.index(trimmedMask.endIndex,
                                             offsetBy: -Constants.phoneMaxLength,
                                             limitedBy: trimmedMask.startIndex) {
            countryCodeLength = trimmedMask[..<maskIndex].count
        } else {
            countryCodeLength = 0
        }
    }
}

// MARK: - Constants
private extension PhoneNumberFormatter {
    enum Constants {
        static let specifyFormatSymbol = "X"
        static let phoneMaxLength = 10
        static let defaultPhoneMask = "(XXX) XXX-XX-XX"
    }
}
