import UIKit

extension UIContentSizeCategory {
    private static let accessibilityCategories: [UIContentSizeCategory] = [
        .accessibilityExtraExtraExtraLarge,
        .accessibilityExtraExtraLarge,
        .accessibilityExtraLarge,
        .accessibilityLarge,
        .accessibilityMedium,
    ]

    var isAccessibilitySizeCategory: Bool {
        if #available(iOS 11.0, *) {
            return isAccessibilityCategory
        } else {
            return UIContentSizeCategory.accessibilityCategories.contains(self)
        }
    }
}
