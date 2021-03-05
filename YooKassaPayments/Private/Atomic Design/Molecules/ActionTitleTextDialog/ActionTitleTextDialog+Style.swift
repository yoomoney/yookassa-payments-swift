import UIKit

// MARK: - Styles

extension ActionTitleTextDialog {

    enum Styles {

        /// Style for `default` ActionTitleTextDialog.
        static let `default` = UIView.Styles.transparent +
            InternalStyle(name: "ActionTitleTextDialog.default") { (view: ActionTitleTextDialog) in
                view.titleLabel.setStyles(UILabel.DynamicStyle.title2,
                                          UILabel.ColorStyle.primary,
                                          UILabel.Styles.multiline,
                                          UILabel.Styles.alignCenter)
                view.textLabel.setStyles(UILabel.DynamicStyle.body,
                                         UILabel.ColorStyle.secondary,
                                         UILabel.Styles.multiline,
                                         UILabel.Styles.alignCenter)
                view.button.setStyles(UIButton.DynamicStyle.flat)
            }
        
        /// Style for a ActionTitleTextDialog to represent fail state.
        ///
        /// default style
        /// icon: fail with tintColor
        static let fail =
            ActionTitleTextDialog.Styles.`default` +
            InternalStyle(name: "ActionTitleTextDialog.fail") { (view: ActionTitleTextDialog) in
                view.iconView.image = UIImage.PlaceholderView.commonFail
            }
    }
}
