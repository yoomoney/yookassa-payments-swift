/* The MIT License
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

/// Class for storing stylist's styles.
///
/// - note: Don't use manualy.
final class StyleStorage {
    /// Stored styles.
    ///
    /// - note: Don't use manualy.
    var styles: [String: [(Stylable) -> Void]] = [:]

    private init() { }

    /// Shared stylist storage.
    ///
    /// - note: Don't use manualy.
    static let shared = StyleStorage()

    /// Register style the processing method for key.
    ///
    /// - note: Don't call manualy, use `Style.init(name:process:)` instead.
    ///
    /// - parameter name: the name of the style
    /// - parameter process: a method of processing style
    func register<T: Stylable>(name: String, process: @escaping (T) -> Void) {
        let wrappingStyle = { (view: Stylable) in
            guard let view = view as? T else {
                return
            }
            process(view)
        }

        if styles[name] == nil {
            styles[name] = [wrappingStyle]
        } else {
            styles[name]?.append(wrappingStyle)
        }
    }
}
