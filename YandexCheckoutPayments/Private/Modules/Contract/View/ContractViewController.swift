import FunctionalSwift
import UIKit

class ContractViewController: UIViewController, PlaceholderProvider {

    // MARK: - VIPER module properties

    var output: ContractViewOutput!

    // MARK: - UI properties

    let templateViewController = ContractTemplate()

    private var backgroundStyle = UIView.Styles.grayBackground

    fileprivate var activityIndicatorView: UIView?

    var paymentMethodView: UIView! {
        didSet {
            paymentMethodView.setStyles(backgroundStyle)
        }
    }

    var additionalView: UIView? {
        didSet {
            additionalView?.setStyles(backgroundStyle)
        }
    }

    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addChild(templateViewController)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        addChild(templateViewController)
    }

    // MARK: - PlaceholderProvider

    lazy var placeholderView: PlaceholderView = {
        $0.setStyles(UIView.Styles.defaultBackground)
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentView = self.actionTextDialog
        return $0
    }(PlaceholderView())

    lazy var actionTextDialog: ActionTextDialog = {
        $0.buttonTitle = §Localized.PlaceholderView.buttonTitle
        $0.setStyles(ActionTextDialog.Styles.fail, ActionTextDialog.Styles.light)
        $0.delegate = self.output
        return $0
    }(ActionTextDialog())

    // MARK: - Managing the View

    override func loadView() {
        view = UIView()
        view.setStyles(backgroundStyle)

        loadSubviews()
        loadConstraints()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        output.setupView()
    }

    private func loadSubviews() {
        view.layoutMargins = UIEdgeInsets(top: Space.double,
                                          left: Space.double,
                                          bottom: Space.double,
                                          right: Space.double)

        templateViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(templateViewController.view)
        templateViewController.paymentMethodView = paymentMethodView

        if let additionalView = additionalView {
            templateViewController.footerView = additionalView
        }
    }

    private func loadConstraints() {
        let constraints = [
            templateViewController.view.leading.constraint(equalTo: view.leading),
            templateViewController.view.trailing.constraint(equalTo: view.trailing),
            templateViewController.view.top.constraint(equalTo: view.top),
            templateViewController.view.bottom.constraint(equalTo: view.bottom),
        ]

        NSLayoutConstraint.activate(constraints)
    }
}

// MARK: - Presentable

extension ContractViewController: Presentable {
    var iPhonePresentationStyle: PresentationStyle {
        return .actionSheet
    }

    var iPadPresentationStyle: PresentationStyle {
        return .pageSheet
    }
    var hasNavigationBar: Bool {
        return false
    }
}

// MARK: - ContractViewInput

extension ContractViewController: ContractViewInput {

    func showActivity() {
        guard self.activityIndicatorView == nil else { return }

        let activityIndicatorView = ActivityIndicatorView()
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.activity.startAnimating()
        activityIndicatorView.setStyles(ActivityIndicatorView.Styles.heavyLight)
        view.addSubview(activityIndicatorView)

        self.activityIndicatorView = activityIndicatorView

        let constraints = [
            activityIndicatorView.leading.constraint(equalTo: view.leading),
            activityIndicatorView.trailing.constraint(equalTo: view.trailing),
            activityIndicatorView.top.constraint(equalTo: view.top),
            activityIndicatorView.bottom.constraint(equalTo: view.bottom),
        ]

        NSLayoutConstraint.activate(constraints)
    }

    func hideActivity() {
        UIView.animate(withDuration: 0.2,
                       animations: {
                           self.activityIndicatorView?.alpha = 0
                       },
                       completion: { _ in
                           self.activityIndicatorView?.removeFromSuperview()
                           self.activityIndicatorView = nil
                       })
    }

    func endEditing(_ force: Bool) {
        view.endEditing(force)
    }

    func showPlaceholder(state: ContractPlaceholderState) {
        switch state {
        case .message(let message):
            showPlaceholder(message: message)
        case .failResendSmsCode:
            showPlaceholder(message: §Localized.PlaceholderView.failResendSmsCode)
        case .authCheckInvalidContext(let message, _):
            showPlaceholder(message: message)
        case .sessionBroken(let message, _):
            showPlaceholder(message: message)
        case .verifyAttemptsExceeded(let message, _):
            showPlaceholder(message: message)
        case .executeError(let message, _):
            showPlaceholder(message: message)
        }
    }

    private func showPlaceholder(message: String) {
        actionTextDialog.title = message
        showPlaceholder()
    }
}

// MARK: - PlaceholderPresenting

extension ContractViewController: PlaceholderPresenting {}

// MARK: - Localized

private extension ContractViewController {
    enum Localized {

        enum PlaceholderView: String {
            case buttonTitle = "Common.PlaceholderView.buttonTitle"

            case failResendSmsCode = "Contract.PlaceholderView.failResendSmsCode"
        }
    }
}
