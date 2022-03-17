/* The MIT License
 *
 * Copyright © 2022 NBCO YooMoney LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

/// Service for determination card type and validate card data.
class CardService {

    /// Card validation errors
    enum ValidationError: Error {
        /// Pan must be filled
        case panEmpty
        /// Length of pan is invalid
        case panInvalidLength
        /// Pan not been verified by the Luhn algorithm
        case luhnAlgorithmFail
        /// Expiry date must be filled
        case expiryDateEmpty
        /// Invalid month
        case invalidMonth
        /// Expiration date is expired
        case expirationDateIsExpired
        /// CSC is invalid length
        case cscInvalidLength
    }

    /// Validate card data model.
    ///
    /// - parameter card: card model for validation
    ///
    /// - returns: array of `CardService.ValidationError` with validation errors or nil if validation success.
    func validate(cardData: CardData) -> [ValidationError]? {

        // SwiftLint bug
        // swiftlint:disable opening_brace
        let validators: [() throws -> Void] = [
            { try self.validate(pan: cardData.pan) },
            { try self.validate(dateComponents: cardData.expiryDate) },
            { try self.validate(csc: cardData.csc) },
        ]
        // swiftlint:enable opening_brace

        let errors = validators.compactMap(collectError)

        return errors.isEmpty ? nil : errors
    }
}

// MARK: - Validation

extension CardService {

    /// Validate pan.
    ///
    /// - parameter pan: pan
    ///
    /// - throws: `ValidationError.panInvalidLength` or `ValidationError.luhnAlgorithmFail`
    func validate(pan: String?) throws {
        guard let pan = pan,
              !pan.isEmpty else {
            throw ValidationError.panEmpty
        }
        try validateLength(pan: pan)
        try validateLuhn(pan: pan)
    }

    /// Validate card expiry date.
    ///
    /// - parameter expiryDate: card expiry date
    ///
    /// - throws: `ValidationError.expirationDateIsExpired`
    func validate(dateComponents: DateComponents?) throws {
        guard let components = dateComponents else { throw ValidationError.expiryDateEmpty }
        guard let month = components.month, month <= 12, month > 0 else { throw ValidationError.invalidMonth }
        guard let expiryDate = components.date else { throw ValidationError.expiryDateEmpty }

        /// Temporarily restrict card expiry date to 01.2022
        /// https://jira.yooteam.ru/browse/MOC-2725
        ///
//        let currentDateComponents: DateComponents = Calendar.current.dateComponents([.year, .month], from: Date())
//        guard let currentDate = Calendar(identifier: .gregorian).date(from: currentDateComponents) else {
//            throw ValidationError.expirationDateIsExpired
//        }

        guard let currentDate = DateComponents(
            calendar: .current,
            timeZone: .current,
            year: 2022,
            month: 1
        ).date else {
            throw ValidationError.expiryDateEmpty
        }

        if currentDate > expiryDate {
            throw ValidationError.expirationDateIsExpired
        }
    }

    func validate(csc: String?) throws {
        guard 3...4 ~= csc?.count ?? 0 else { throw ValidationError.cscInvalidLength }
    }

    /// Validate pan length.
    ///
    /// - parameter pan: pan
    ///
    /// - throws: `ValidationError.panInvalidLength`
    func validateLength(pan: String) throws {
        let panLength = pan.count

        // Validate default pan length
        if (13...19 ~= panLength) == false {
            throw ValidationError.panInvalidLength
        }
    }

    /// Validate pan by Luhn algorithm.
    ///
    /// - parameter pan: pan
    ///
    /// - throws: `ValidationError.panInvalidLength`
    func validateLuhn(pan: String) throws {

        let lengthIsOdd = pan.count % 2 == 0
        var panNumbers = pan.compactMap { Int(String($0)) }
        for i in stride(from: lengthIsOdd ? 0 : 1, to: panNumbers.count, by: 2) {
            var number = panNumbers[i] * 2
            if number > 9 {
                number -= 9
            }
            panNumbers[i] = number
        }

        if panNumbers.reduce(0, +) % 10 != 0 {
            throw ValidationError.luhnAlgorithmFail
        }
    }
}

// MARK: - Private helpers

private extension CardService {

    /// Call and unwrap `ValidationError` from throws closure to `Optional<ValidationError>`
    ///
    /// - parameter closure: function that can throws `ValidationError`
    ///
    /// - returns: `ValidationError` if closure throws error else `nil`
    func collectError(_ closure: @escaping () throws -> Void) -> ValidationError? {
        do {
            try closure()
        } catch {
            if let error = error as? ValidationError {
                return error
            }
        }
        return nil
    }
}
