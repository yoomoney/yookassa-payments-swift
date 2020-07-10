import UIKit

// MARK: - Styles
extension IconItemView {
    enum Styles {

        enum Tint {

            static let normal = InternalStyle(name: "IconItemView.Tint.normal") { (view: IconItemView) in
                view.iconView.setStyles(IconView.Styles.Tint.normal)
            }

            static let highlighted = InternalStyle(name: "IconItemView.Tint.highlighted") { (view: IconItemView) in
                view.iconView.setStyles(IconView.Styles.Tint.highlighted)
            }

            static let disabled = InternalStyle(name: "IconItemView.Tint.disabled") { (view: IconItemView) in
                view.iconView.setStyles(IconView.Styles.Tint.disabled)
            }

            static let selected = InternalStyle(name: "IconItemView.Tint.selected") { (view: IconItemView) in
                view.iconView.setStyles(IconView.Styles.Tint.selected)
            }
        }

        enum InverseBackgroundTint {

            static let normal = UIView.Styles.transparent
                + InternalStyle(name: "IconItemView.InverseBackgroundTint.normal") { (view: IconItemView) in
                    view.iconView.setStyles(IconView.Styles.InverseBackgroundTint.normal)
                }

            static let highlighted = normal
                + InternalStyle(name: "IconItemView.InverseBackgroundTint.highlighted") { (view: IconItemView) in
                    view.iconView.setStyles(IconView.Styles.InverseBackgroundTint.highlighted)
                }

            static let disabled = normal
                + InternalStyle(name: "IconItemView.InverseBackgroundTint.disabled") { (view: IconItemView) in
                    view.iconView.setStyles(IconView.Styles.InverseBackgroundTint.disabled)
                }
        }

        enum FadeTint {

            static let normal = UIView.Styles.transparent
                + InternalStyle(name: "IconItemView.FadeTint.normal") { (view: IconItemView) in
                    view.iconView.setStyles(IconView.Styles.FadeTint.normal)
                }

            static let highlighted = normal
                + InternalStyle(name: "IconItemView.FadeTint.highlighted") { (view: IconItemView) in
                    view.iconView.setStyles(IconView.Styles.FadeTint.highlighted)
                }

            static let disabled = normal
                + InternalStyle(name: "IconItemView.FadeTint.disabled") { (view: IconItemView) in
                    view.iconView.setStyles(IconView.Styles.FadeTint.disabled)
                }
        }
    }
}
