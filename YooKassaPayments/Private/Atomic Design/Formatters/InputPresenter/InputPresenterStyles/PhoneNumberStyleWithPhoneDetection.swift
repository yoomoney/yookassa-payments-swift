/*
 * The MIT License (MIT)
 *
 * Copyright © 2020 NBCO YooMoney LLC
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

struct PhoneNumberStyleWithPhoneDetection: InputPresenterStyle {
    fileprivate let phoneNumberFormatter: PhoneNumberFormatter

    init(phoneNumberFormatter: PhoneNumberFormatter) {
        self.phoneNumberFormatter = phoneNumberFormatter
    }

    func removedFormatting(from string: String) -> String {
        if phoneNumberFormatter.isPhone(string: string) {
            return string.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        } else {
            return string
        }
    }

    func appendedFormatting(to string: String) -> String {
        if phoneNumberFormatter.isPhone(string: string) {
            var newString = string
            if string.hasPrefix("8") {
                let index =
                    string.index(string.startIndex, offsetBy: 1, limitedBy: string.endIndex) ?? string.startIndex
                newString = "7" + string[index...]
            }
            return phoneNumberFormatter.format(phone: newString)
        } else {
            return string
        }
    }

    var maximalLength: Int {
        return phoneNumberFormatter.countryCodeLength + phoneNumberFormatter.phoneMaxLength
    }
}
