import UIKit.UIImage

protocol PaymentMethodsViewInput: ActivityIndicatorFullViewPresenting, NotificationPresenting {
    func reloadData()
    func setLogoVisible(image: UIImage, isVisible: Bool)

    func showPlaceholder(message: String)
    func hidePlaceholder()
}

protocol PaymentMethodsViewOutput: ActionTitleTextDialogDelegate {
    func setupView()
    func viewDidAppear()
    func applicationDidBecomeActive()
    func numberOfRows() -> Int
    func viewModelForRow(at indexPath: IndexPath) -> PaymentMethodViewModel?
    func didSelect(at indexPath: IndexPath)
    func didPressSettings(at indexPath: IndexPath)
}
