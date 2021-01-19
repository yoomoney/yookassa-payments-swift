import UIKit

protocol SuccessViewControllerDelegate: class {
    func didPressDocumentationButton(on successViewController: SuccessViewController)
    func didPressSendTokenButton(on successViewController: SuccessViewController)
    func didPressClose(on successViewController: SuccessViewController)
}

final class SuccessViewController: UIViewController {

    weak var delegate: SuccessViewControllerDelegate?

    // MARK: - UI properties

    private lazy var dialog: ActionTextDialog = {
        let dialog = ActionTextDialog()
        dialog.setStyles(ActionTextDialog.Styles.default,
                         ActionTextDialog.Styles.agreement)
        dialog.title = translate(Localized.description)
        dialog.buttonTitle = translate(Localized.documentation)
        dialog.icon = #imageLiteral(resourceName: "Common.placeholderView.success")
        dialog.delegate = self
        return dialog
    }()

    private lazy var sendTokenButton: UIButton = {
        let sendTokenButton = UIButton(type: .custom)
        sendTokenButton.setStyles(UIButton.DynamicStyle.flat)
        sendTokenButton.setStyledTitle(translate(Localized.sendToken), for: .normal)
        sendTokenButton.addTarget(self, action: #selector(sendTokenDidPress), for: .touchUpInside)
        return sendTokenButton
    }()

    private lazy var closeBarItem: UIBarButtonItem = {
        let closeBarItem = UIBarButtonItem()
        closeBarItem.style = .plain
        closeBarItem.image = .templatedClose
        closeBarItem.target = self
        closeBarItem.action = #selector(closeDidPress)
        return closeBarItem
    }()

    // MARK: - Managing the View

    override func loadView() {
        let view = UIView()

        loadSubviews(to: view)
        loadConstraints(to: view)

        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }

        navigationItem.leftBarButtonItem = closeBarItem
    }

    private func loadSubviews(to view: UIView) {
        [
            dialog,
            sendTokenButton,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }

    private func loadConstraints(to view: UIView) {
        let constraints = [
            dialog.leading.constraint(equalTo: view.leading),
            dialog.trailing.constraint(equalTo: view.trailing),
            dialog.centerY.constraint(equalTo: view.centerY),
            view.bottom.constraint(equalTo: sendTokenButton.bottom, constant: Space.double),
            sendTokenButton.centerX.constraint(equalTo: view.centerX),
        ]

        NSLayoutConstraint.activate(constraints)
    }

    // MARK: - Actions

    @objc
    private func sendTokenDidPress() {
        delegate?.didPressSendTokenButton(on: self)
    }

    @objc
    private func closeDidPress() {
        delegate?.didPressClose(on: self)
    }
}

// MARK: - ActionTextDialogDelegate

extension SuccessViewController: ActionTextDialogDelegate {
    public func didPressButton() {
        delegate?.didPressDocumentationButton(on: self)
    }
}

// MARK: - Localized

private extension SuccessViewController {
    enum Localized: String {
        case description = "success.description"
        case documentation = "success.button.docs"
        case sendToken = "success.button.send_token"
    }
}
