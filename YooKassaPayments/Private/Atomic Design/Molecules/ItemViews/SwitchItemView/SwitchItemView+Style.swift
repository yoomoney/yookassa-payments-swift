import UIKit

extension SwitchItemView {

    enum Styles {

        /// Style for primary switch item view.
        ///
        /// default background color, body multiline title, tint switch.
        static let primary =
            UIView.Styles.defaultBackground +
            InternalStyle(name: "SwitchItemView.primary") { (item: SwitchItemView) in
                item.titleLabel.setStyles(UILabel.DynamicStyle.body,
                                          UILabel.Styles.multiline)
                item.switchControl.onTintColor = item.tintColor
            }

        /// Style for secondary switch item view.
        ///
        /// default background color, caption1 secondary multiline title, tint switch.
        static let secondary =
            UIView.Styles.defaultBackground +
            InternalStyle(name: "SwitchItemView.secondary") { (item: SwitchItemView) in
                item.titleLabel.setStyles(UILabel.DynamicStyle.caption1,
                                          UILabel.Styles.multiline,
                                          UILabel.ColorStyle.secondary)
                item.switchControl.onTintColor = item.tintColor
            }
    }
}
