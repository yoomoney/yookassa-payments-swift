import UIKit

final class SavePaymentMethodInfoViewController: UIViewController {

    // MARK: - VIPER

    var output: SavePaymentMethodInfoViewOutput!

    // MARK: - UI properties

    private lazy var scrollView: UIScrollView = {
        $0.setStyles(UIView.Styles.grayBackground)
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIScrollView())

    private lazy var contentView: UIView = {
        $0.setStyles(UIView.Styles.grayBackground)
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIView())

    private lazy var contentStackView: UIStackView = {
        $0.setStyles(UIView.Styles.grayBackground)
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .vertical
        $0.spacing = Space.double
        return $0
    }(UIStackView())

    private lazy var headerLabel: UILabel = {
        let view = UILabel()
        view.setStyles(
            UILabel.DynamicStyle.title1,
            UILabel.ColorStyle.primary,
            UILabel.Styles.multiline
        )
        return view
    }()

    private lazy var bodyLabel: UILabel = {
        let view = UILabel()
        view.setStyles(
            UILabel.DynamicStyle.body,
            UILabel.ColorStyle.secondary,
            UILabel.Styles.multiline
        )
        return view
    }()

    private lazy var closeBarButtonItem: UIBarButtonItem = {
        $0.tintColor = CustomizationStorage.shared.mainScheme
        return $0
    }(UIBarButtonItem(
        image: UIImage.named("Common.close"),
        style: .plain,
        target: self,
        action: #selector(closeBarButtonItemDidPress)
    ))

    fileprivate lazy var actionButtonStackView: UIStackView = {
        $0.setStyles(UIView.Styles.grayBackground)
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .vertical
        return $0
    }(UIStackView())

    private lazy var gotItButton: Button = {
        $0.tintColor = CustomizationStorage.shared.mainScheme
        $0.setStyles(
            UIButton.DynamicStyle.primary,
            UIView.Styles.heightAsContent
        )
        $0.setStyledTitle(§Localized.buttonGotIt, for: .normal)
        $0.addTarget(
            self,
            action: #selector(closeBarButtonItemDidPress),
            for: .touchUpInside
        )
        return $0
    }(Button(type: .custom))

    // MARK: - Managing the View

    override func loadView() {
        view = UIView()
        view.setStyles(UIView.Styles.grayBackground)
        navigationController?.navigationBar.setStyles(UINavigationBar.Styles.default)
        navigationItem.leftBarButtonItem = closeBarButtonItem

        setupView()
        setupConstraints()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        output.setupView()
    }

    private func setupView() {
        [
            scrollView,
            actionButtonStackView,
        ].forEach(view.addSubview)

        scrollView.addSubview(contentView)

        [
            contentStackView,
        ].forEach(contentView.addSubview)

        [
            headerLabel,
            bodyLabel,
        ].forEach(contentStackView.addArrangedSubview)

        [
            gotItButton,
        ].forEach(actionButtonStackView.addArrangedSubview)
    }

    private func setupConstraints() {
        let bottomConstraint: NSLayoutConstraint
        let topConstraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
            bottomConstraint = actionButtonStackView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -Space.double
            )
            topConstraint = scrollView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            )
        } else {
            bottomConstraint = actionButtonStackView.bottomAnchor.constraint(
                equalTo: bottomLayoutGuide.topAnchor,
                constant: -Space.double
            )
            topConstraint = scrollView.topAnchor.constraint(
                equalTo: topLayoutGuide.bottomAnchor
            )
        }

        let constraints = [
            topConstraint,
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Space.double),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Space.double),
            scrollView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor,
                constant: -Space.double
            ),

            actionButtonStackView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: Space.double
            ),
            actionButtonStackView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -Space.double
            ),
            bottomConstraint,

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ]
        NSLayoutConstraint.activate(constraints)
    }
}

// MARK: - Actions

private extension SavePaymentMethodInfoViewController {
    @objc
    func closeBarButtonItemDidPress(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - SavePaymentMethodInfoViewInput

extension SavePaymentMethodInfoViewController: SavePaymentMethodInfoViewInput {
    func setSavePaymentMethodInfoViewModel(
        _ viewModel: SavePaymentMethodInfoViewModel
    ) {
        headerLabel.text = viewModel.headerText
        bodyLabel.text = viewModel.bodyText
        view.layoutIfNeeded()
        view.setNeedsLayout()
    }
}

// MARK: - Localized

private extension SavePaymentMethodInfoViewController {
    enum Localized: String {
        case buttonGotIt = "SavePaymentMethodInfo.Button.GotIt"
    }
}
