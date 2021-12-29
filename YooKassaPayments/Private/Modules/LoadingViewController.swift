import UIKit

class LoadingViewController: UIViewController, PlaceholderProvider, ActivityIndicatorPresenting {
    var reloadHandler: (() -> Void)?

    // MARK: - PlaceholderProvider

    lazy var placeholderView: PlaceholderView = {
        $0.setStyles(UIView.Styles.defaultBackground)
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentView = self.actionTitleTextDialog
        return $0
    }(PlaceholderView())

    private lazy var actionTitleTextDialog: ActionTitleTextDialog = {
        $0.tintColor = CustomizationStorage.shared.mainScheme
        $0.setStyles(ActionTitleTextDialog.Styles.fail)
        $0.text = CommonLocalized.PlaceholderView.text
        $0.buttonTitle = CommonLocalized.PlaceholderView.buttonTitle
        $0.delegate = self
        return $0
    }(ActionTitleTextDialog())
}

// MARK: - ActivityIndicatorFullViewPresenting

extension LoadingViewController: ActivityIndicatorFullViewPresenting {
    func showActivity() {
        showFullViewActivity(style: ActivityIndicatorView.Styles.heavyLight)
    }

    func hideActivity() {
        hideFullViewActivity()
    }
}

extension LoadingViewController: ActionTitleTextDialogDelegate {
    func didPressButton(in actionTitleTextDialog: ActionTitleTextDialog) {
        reloadHandler?()
    }
}
