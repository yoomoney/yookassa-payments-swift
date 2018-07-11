import UIKit

// MARK: - Styles
extension UIImageView {

    enum Styles {

        // MARK: - Main styles

        /// Style for dynamic size image view.
        ///
        /// scale aspect fill content mode, adjusts image size for accessibility content size category is on.
        static let dynamicSize = Style(name: "UIImageView.dynamicSize") { (imageView: UIImageView) in
            if #available(iOS 11.0, *) {
                imageView.adjustsImageSizeForAccessibilityContentSizeCategory = true
            }
            imageView.contentMode = .scaleAspectFill
        }

        // MARK: - Internal styles

        /// Style for badge image view.
        ///
        /// dynamic size, rounded, triple diameter, white background.
        static let badge = dynamicSize +
            Style(name: "UIImageView.badge") { (imageView: UIImageView) in
                imageView.backgroundColor = .white
                imageView.layer.cornerRadius = Space.triple / 2
                imageView.clipsToBounds = true
                imageView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    imageView.height.constraint(equalToConstant: Space.triple),
                    imageView.width.constraint(equalTo: imageView.height),
                ])
            }
    }
}
