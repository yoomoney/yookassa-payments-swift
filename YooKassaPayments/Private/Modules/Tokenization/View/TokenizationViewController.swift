import class PassKit.PKPaymentAuthorizationViewController
import UIKit

final class TokenizationViewController: UIViewController {

    // MARK: - VIPER

    var output: (TokenizationViewOutput & TokenizationModuleInput)!

    // MARK: - Configuring the View Rotation Settings

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {

        let result: UIInterfaceOrientationMask

        if UIDevice.current.isIphonePlus {
            result = .allButUpsideDown
        } else if case .pad = UIDevice.current.userInterfaceIdiom {
            result = .all
        } else {
            result = .portrait
        }

        return result
    }

    // MARK: - Managing the View

    override func viewDidLoad() {
        super.viewDidLoad()
        output.setupView()

        if UIDevice.current.isIphonePlus == false {
            // https://stackoverflow.com/a/26358192/6108456
            // The only option of forced transfer to portrait mode.
            let value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        }
    }
}

// MARK: - TokenizationViewInput

extension TokenizationViewController: TokenizationViewInput {
    func setCustomizationSettings(_ customizationSettings: CustomizationSettings) {
        view.tintColor = customizationSettings.mainScheme
    }
}

// MARK: - TokenizationModuleInput

extension TokenizationViewController: TokenizationModuleInput {
    func start3dsProcess(requestUrl: String) {
        output.start3dsProcess(requestUrl: requestUrl)
    }
}
