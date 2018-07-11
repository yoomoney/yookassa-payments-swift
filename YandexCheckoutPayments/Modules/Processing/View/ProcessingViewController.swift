import UIKit

final class ProcessingViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        showFullViewActivity(style: ActivityIndicatorView.Styles.heavyLight)
    }
}

extension ProcessingViewController: ActivityIndicatorFullViewPresenting {}
