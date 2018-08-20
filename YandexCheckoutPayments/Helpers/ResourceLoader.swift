import Foundation
import UIKit.UIImage

extension Bundle {
    static var framework: Bundle {
        class Class {}
        let frameworkBundle = Bundle(for: Class.self)
        let resourcesPath = frameworkBundle.path(forResource: "YandexCheckoutPayments", ofType: "bundle")!
        return Bundle(path: resourcesPath)!
    }
}

extension UIImage {
    static func named(_ name: String) -> UIImage {
        guard let image = UIImage(named: name, in: Bundle.framework, compatibleWith: nil) else {
            assertionFailure("Image '\(name)' not found")
            return UIImage()
        }
        return image
    }
}
