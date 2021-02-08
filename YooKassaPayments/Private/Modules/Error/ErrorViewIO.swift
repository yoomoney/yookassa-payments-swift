import UIKit.UIImage

protocol ErrorViewInput: class, PlaceholderPresenting {
    func showPlaceholder(message: String)
}

protocol ErrorViewOutput: ActionTitleTextDialogDelegate {
    func setupView()
}
