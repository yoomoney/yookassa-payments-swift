import UIKit

extension LinkedSwitchItemView {

    enum Styles {

        /// Style for primary switch item view.
        ///
        /// default background color, body multiline title, tint switch.
        static let primary =
            UIView.Styles.defaultBackground +
                Style(name: "LinkedSwitchItemView.primary") { (item: LinkedSwitchItemView) in
                    item.switchControl.onTintColor = item.tintColor
                }
    }
}
