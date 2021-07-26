import UIKit

extension LargeIconButtonItemView {
    enum Styles {

        static let secondary = InternalStyle(
            name: "LargeIconButtonItemView.secondary"
        ) { (item: LargeIconButtonItemView) in
            item.titleLabel.setStyles(
                UILabel.DynamicStyle.body,
                UILabel.ColorStyle.primary
            )
            item.subtitleLabel.setStyles(
                UILabel.DynamicStyle.bodyMedium,
                UILabel.ColorStyle.secondary
            )
        }
    }
}
