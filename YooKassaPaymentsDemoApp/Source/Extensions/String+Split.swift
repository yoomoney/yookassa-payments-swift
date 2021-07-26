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

extension String {

    /// The method splits the string into equal parts by `n` characters.
    ///
    /// - Parameter n: The length of one of the received part.
    /// - Parameter separator: The separator between parts of.
    ///
    /// - Returns: Formatted string.
    func splitEvery(_ n: Int, separator: String) -> String {
        return splitEvery(n).joined(separator: separator)
    }

    /// The method splits the string into equal parts by `n` characters.
    ///
    /// - Parameter n: The length of one of the received part.
    ///
    /// - Returns: An array of string parts.
    func splitEvery(_ n: Int) -> [String] {
        return stride(from: 0, to: count, by: n).map {
            substring(from: $0, count: n)
        }
    }

    private func substring(from i: Int, count n: Int) -> String {
        let start = index(startIndex, offsetBy: i)
        let end = index(start, offsetBy: n, limitedBy: endIndex) ?? endIndex
        return String(self[start..<end])
    }
}
