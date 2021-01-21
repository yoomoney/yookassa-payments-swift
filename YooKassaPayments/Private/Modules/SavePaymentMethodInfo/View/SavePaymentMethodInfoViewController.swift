import UIKit

final class SavePaymentMethodInfoViewController: UIViewController {

    // MARK: - VIPER

    var output: SavePaymentMethodInfoViewOutput!

    // MARK: - UI properties

    private lazy var headerLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false

        let dynamicStyle: InternalStyle
        if #available(iOS 9.0, *) {
            dynamicStyle = UILabel.DynamicStyle.title3
        } else {
            dynamicStyle = UILabel.DynamicStyle.headline3
        }

        view.setStyles(
            dynamicStyle,
            UILabel.Styles.multiline
        )
        return view
    }()

    private lazy var bodyLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setStyles(
            UILabel.DynamicStyle.body,
            UILabel.Styles.multiline
        )
        return view
    }()

    private lazy var closeBarButtonItem = UIBarButtonItem(
        image: UIImage.named("Common.close"),
        style: .plain,
        target: self,
        action: #selector(closeBarButtonItemDidPress)
    )

    // MARK: - Managing the View

    override func loadView() {
        view = UIView()
        view.setStyles(UIView.Styles.grayBackground)
        navigationController?.navigationBar.setStyles(UINavigationBar.Styles.default)
        setupView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        output.setupView()
        navigationItem.leftBarButtonItem = closeBarButtonItem
    }

    private func setupView() {
        [
            headerLabel,
            bodyLabel,
        ].forEach(view.addSubview)

        let constraints = [
            headerLabel.top.constraint(equalTo: view.topMargin, constant: Space.double),
            headerLabel.leading.constraint(equalTo: view.leadingMargin),
            headerLabel.trailing.constraint(equalTo: view.trailingMargin),
            bodyLabel.top.constraint(equalTo: headerLabel.bottom, constant: Space.double),
            bodyLabel.leading.constraint(equalTo: view.leadingMargin),
            bodyLabel.trailing.constraint(equalTo: view.trailingMargin),
            bodyLabel.bottom.constraint(lessThanOrEqualTo: view.bottomMargin),
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
    }

    func setCustomizationSettings(
        _ customizationSettings: CustomizationSettings
    ) {
        closeBarButtonItem.tintColor = customizationSettings.mainScheme
    }
}
