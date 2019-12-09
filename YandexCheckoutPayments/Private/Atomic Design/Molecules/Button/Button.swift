import UIKit

class Button: UIButton {
    override func tintColorDidChange() {
        applyStyles()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        applyStyles()
    }
}
