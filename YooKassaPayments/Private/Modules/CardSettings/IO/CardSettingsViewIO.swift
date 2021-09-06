import UIKit

protocol CardSettingsViewInput: NotificationPresenting, ActivityIndicatorFullViewPresenting {
    func set(
        title: String,
        cardMaskHint: String,
        cardLogo: UIImage,
        cardMask: String,
        cardTitle: String,
        informerMessage: String,
        canUnbind: Bool
    )
    func hideSubmit(_ hide: Bool)
    func disableSubmit()
    func enableSubmit()
}
protocol CardSettingsViewOutput: AnyObject {
    func setupView()
    func didPressSubmit()
    func didPressInformerMoreInfo()
}
