import UIKit

// MARK: - Styles
extension IconItemView {
    enum Styles {

        enum Tint {

            static let normal = Style(name: "IconItemView.Tint.normal") { (view: IconItemView) in
                view.iconView.setStyles(IconView.Styles.Tint.normal)
            }

            static let highlighted = Style(name: "IconItemView.Tint.highlighted") { (view: IconItemView) in
                view.iconView.setStyles(IconView.Styles.Tint.highlighted)
            }

            static let disabled = Style(name: "IconItemView.Tint.disabled") { (view: IconItemView) in
                view.iconView.setStyles(IconView.Styles.Tint.disabled)
            }

            static let selected = Style(name: "IconItemView.Tint.selected") { (view: IconItemView) in
                view.iconView.setStyles(IconView.Styles.Tint.selected)
            }
        }

        enum InverseBackgroundTint {

            static let normal = UIView.Styles.transparent
                + Style(name: "IconItemView.InverseBackgroundTint.normal") { (view: IconItemView) in
                    view.iconView.setStyles(IconView.Styles.InverseBackgroundTint.normal)
                }

            static let highlighted = normal
                + Style(name: "IconItemView.InverseBackgroundTint.highlighted") { (view: IconItemView) in
                    view.iconView.setStyles(IconView.Styles.InverseBackgroundTint.highlighted)
                }

            static let disabled = normal
                + Style(name: "IconItemView.InverseBackgroundTint.disabled") { (view: IconItemView) in
                    view.iconView.setStyles(IconView.Styles.InverseBackgroundTint.disabled)
                }
        }

        enum FadeTint {

            static let normal = UIView.Styles.transparent
                + Style(name: "IconItemView.FadeTint.normal") { (view: IconItemView) in
                    view.iconView.setStyles(IconView.Styles.FadeTint.normal)
                }

            static let highlighted = normal
                + Style(name: "IconItemView.FadeTint.highlighted") { (view: IconItemView) in
                    view.iconView.setStyles(IconView.Styles.FadeTint.highlighted)
                }

            static let disabled = normal
                + Style(name: "IconItemView.FadeTint.disabled") { (view: IconItemView) in
                    view.iconView.setStyles(IconView.Styles.FadeTint.disabled)
                }
        }
    }
}
