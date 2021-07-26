import UIKit.UIImage

extension UIImage {
    static func named(_ name: String) -> UIImage {
        guard let image = UIImage(named: name, in: Bundle.framework, compatibleWith: nil) else {
            assertionFailure("Image '\(name)' not found")
            return UIImage()
        }
        return image
    }

    static func localizedImage(_ localizedKey: String) -> UIImage {
        let name = NSLocalizedString(
            localizedKey,
            tableName: "LocalizedResources",
            bundle: Bundle.framework,
            comment: ""
        )
        return UIImage.named(name)
    }
}
