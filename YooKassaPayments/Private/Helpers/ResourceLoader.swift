import UIKit.UIImage

extension UIImage {
    static func named(_ name: String) -> UIImage {
        guard let image = UIImage(named: name, in: Bundle.framework, compatibleWith: nil) else {
            assertionFailure("Image '\(name)' not found")
            return UIImage()
        }
        return image
    }
}
