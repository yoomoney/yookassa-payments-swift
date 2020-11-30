import UIKit

struct WebBrowserOptions: OptionSet {
    let rawValue: Int

    static let navigation = WebBrowserOptions(rawValue: 1 << 0)
    static let update = WebBrowserOptions(rawValue: 1 << 1)
    static let close = WebBrowserOptions(rawValue: 1 << 2)
    static let all: WebBrowserOptions = [.navigation, .update, .close]

    init(rawValue: Int) {
        self.rawValue = rawValue
    }
}
