import UIKit

final class ErrorViewController: UIViewController, PlaceholderProvider {

    // MARK: - VIPER

    var output: ErrorViewOutput!

    // MARK: - UI properties

    lazy var placeholderView: PlaceholderView = {
        $0.setStyles(UIView.Styles.defaultBackground)
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentView = self.actionTitleTextDialog
        return $0
    }(PlaceholderView())

    lazy var actionTitleTextDialog: ActionTitleTextDialog = {
        $0.tintColor = CustomizationStorage.shared.mainScheme
        $0.setStyles(ActionTitleTextDialog.Styles.fail)
        $0.buttonTitle = §Localized.PlaceholderView.repeatButton
        $0.text = §Localized.PlaceholderView.text
        $0.delegate = output
        return $0
    }(ActionTitleTextDialog())

    fileprivate lazy var scrollView = UIScrollView()
    fileprivate lazy var contentView = UIView()

    // MARK: - Managing the view

    override func loadView() {
        view = UIView()
        view.preservesSuperviewLayoutMargins = true
        view.setStyles(UIView.Styles.grayBackground)

        setupConstraints()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        output.setupView()
    }

    private func setupConstraints() {

        let minHeightConstraint = view.height.constraint(equalToConstant: 300)
        minHeightConstraint.priority = .defaultHigh

        let constraints = [
            minHeightConstraint,
        ]

        NSLayoutConstraint.activate(constraints)
    }
}

// MARK: - ErrorViewInput

extension ErrorViewController: ErrorViewInput {
    func showPlaceholder(message: String) {
        actionTitleTextDialog.title = message
        showPlaceholder()
    }
}

extension ErrorViewController: PlaceholderPresenting {

    func showPlaceholder() {

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        let constraints = [
            scrollView.leading.constraint(equalTo: view.leading),
            scrollView.top.constraint(equalTo: view.top),
            scrollView.trailing.constraint(equalTo: view.trailing),
            scrollView.bottom.constraint(equalTo: view.bottom),

            scrollView.leading.constraint(equalTo: contentView.leading),
            scrollView.top.constraint(equalTo: contentView.top),
            scrollView.trailing.constraint(equalTo: contentView.trailing),
            scrollView.bottom.constraint(equalTo: contentView.bottom),
            contentView.width.constraint(equalTo: view.width),
            contentView.height.constraint(equalTo: view.height),
        ]
        NSLayoutConstraint.activate(constraints)

        showPlaceholder(on: contentView)
    }

    func hidePlaceholder() {
        scrollView.removeFromSuperview()
    }
}

// MARK: - Localized

private extension ErrorViewController {
    enum Localized {
        enum PlaceholderView: String {
            case repeatButton = "Error.Button.repeat"
            case text = "Common.PlaceholderView.text"
        }
    }
}
