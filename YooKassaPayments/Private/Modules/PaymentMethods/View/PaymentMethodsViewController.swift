import UIKit

final class PaymentMethodsViewController: UIViewController, PlaceholderProvider {
    // MARK: - VIPER

    var output: PaymentMethodsViewOutput!

    // MARK: - UI properties

    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.setStyles(UIView.Styles.defaultBackground)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.dataSource = self
        view.delegate = self
        view.rowHeight = UITableView.automaticDimension
        view.estimatedRowHeight = Constants.estimatedRowHeight
        view.register(IconButtonItemTableViewCell.self)
        view.register(LargeIconButtonItemViewCell.self)
        view.tableFooterView = UIView()

        if #available(iOS 13.0, *) {
            view.separatorColor = .separator
        } else {
            view.separatorColor = .alto
        }

        return view
    }()

    private var activityIndicatorView: UIView?

    private lazy var scrollView = UIScrollView()
    private lazy var contentView = UIView()

    // MARK: - PlaceholderProvider

    lazy var placeholderView: PlaceholderView = {
        $0.setStyles(UIView.Styles.defaultBackground)
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentView = self.actionTitleTextDialog
        return $0
    }(PlaceholderView())

    lazy var actionTitleTextDialog: ActionTitleTextDialog = {
        $0.tintColor = CustomizationStorage.shared.mainScheme
        $0.setStyles(ActionTitleTextDialog.Styles.fail)
        $0.text = CommonLocalized.PlaceholderView.text
        $0.buttonTitle = CommonLocalized.PlaceholderView.buttonTitle
        $0.delegate = output
        return $0
    }(ActionTitleTextDialog())

    // MARK: - Constraints

    private lazy var tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)

    // MARK: - Init

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Managing the view

    override func loadView() {
        view = UIView()
        view.preservesSuperviewLayoutMargins = true
        view.backgroundColor = .clear
        setupView()
        setupConstraints()
        setupObserver()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        output.setupView()
        setupNavigationBar()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        output.viewDidAppear()
    }

    private func setupView() {
        [
            tableView,
        ].forEach(view.addSubview)
    }

    private func setupConstraints() {
        let constraints = [
            tableViewHeightConstraint,
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ]

        NSLayoutConstraint.activate(constraints)
    }

    private func setupNavigationBar() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        navigationBar.shadowImage = UIImage()
        navigationBar.barTintColor = UIColor.AdaptiveColors.systemBackground
        navigationBar.tintColor = CustomizationStorage.shared.mainScheme

        let leftItem = UILabel()
        leftItem.setStyles(UILabel.DynamicStyle.headline1)
        leftItem.text = Localized.paymentMethods
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftItem)
        if #available(iOS 11.0, *) {
            navigationBar.prefersLargeTitles = false
        }
    }

    private func setupObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didBecomeActiveNotification(_:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    // MARK: - Configuring the View’s Layout Behavior

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async {
            self.fixTableViewHeight()
        }
    }

    private func fixTableViewHeight() {
        let contentEffectiveHeight = tableView.contentSize.height
            + tableView.contentInset.top
            + tableView.contentInset.bottom
            + UIScreen.safeAreaInsets.bottom
            + Constants.navigationBarHeight

        let newValue = output.numberOfRows() == 0
            ? Constants.defaultTableViewHeight
            : contentEffectiveHeight

        if tableViewHeightConstraint.constant != newValue {
            tableViewHeightConstraint.constant = newValue
            NotificationCenter.default.post(
                name: .needUpdatePreferredHeight,
                object: nil
            )
        }
    }

    // MARK: - Actions

    @objc
    private func didBecomeActiveNotification(_ notification: Notification) {
        output.applicationDidBecomeActive()
    }
}

// MARK: - UITableViewDataSource

extension PaymentMethodsViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        output.numberOfRows()
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let viewModel = output.viewModelForRow(at: indexPath) else {
            return .init()
        }

        let cell: UITableViewCell

        if let subtitle = viewModel.subtitle {
            let largeCell = tableView.dequeueReusableCell(
                withType: LargeIconButtonItemViewCell.self,
                for: indexPath
            )
            largeCell.rightButton.setImage(nil, for: .normal)
            largeCell.rightButtonPressHandler = nil
            largeCell.icon = viewModel.image
            largeCell.title = viewModel.title
            largeCell.subtitle = subtitle

            cell = largeCell

            if viewModel.hasActions {
                largeCell.rightButton.setImage(PaymentMethodResources.Image.more, for: .normal)
                largeCell.rightButton.contentEdgeInsets = UIEdgeInsets(
                    top: Space.double, left: Space.double, bottom: Space.double, right: Space.double
                )
                largeCell.rightButtonPressHandler = { [weak self] in
                    self?.output.didPressSettings(at: indexPath)
                }
            }
        } else {
            let smallCell = tableView.dequeueReusableCell(
                withType: IconButtonItemTableViewCell.self,
                for: indexPath
            )
            smallCell.icon = viewModel.image
            smallCell.title = viewModel.title

            cell = smallCell
        }

        cell.appendStyle(UIView.Styles.grayBackground)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension PaymentMethodsViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        estimatedHeightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        output.didSelect(at: indexPath)
    }
}

// MARK: - PaymentMethodsViewInput

extension PaymentMethodsViewController: PaymentMethodsViewInput {
    func reloadData() {
        tableView.reloadData()
    }

    func setLogoVisible(_ isVisible: Bool) {
        guard isVisible else {
            navigationItem.rightBarButtonItem = nil
            return
        }
        let image = UIImageView(image: Resources.kassaLogo)
        let rightItem = UIBarButtonItem(customView: image)
        navigationItem.rightBarButtonItem = rightItem
    }

    func showActivity() {
        guard activityIndicatorView == nil else { return }

        let activityIndicatorView = ActivityIndicatorView()
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.activity.startAnimating()
        activityIndicatorView.setStyles(ActivityIndicatorView.Styles.heavyLight)
        view.addSubview(activityIndicatorView)

        self.activityIndicatorView = activityIndicatorView

        let constraints = [
            activityIndicatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            activityIndicatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            activityIndicatorView.topAnchor.constraint(equalTo: view.topAnchor),
            activityIndicatorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            activityIndicatorView.heightAnchor.constraint(equalToConstant: Constants.defaultTableViewHeight),
        ]

        NSLayoutConstraint.activate(constraints)
    }

    func hideActivity() {
        UIView.animate(
            withDuration: 0.2,
            animations: {
                self.activityIndicatorView?.alpha = 0
            },
            completion: { _ in
                self.activityIndicatorView?.removeFromSuperview()
                self.activityIndicatorView = nil
            }
        )
    }

    func showPlaceholder(message: String) {
        actionTitleTextDialog.title = message
        showPlaceholder()
    }
}

// MARK: - PlaceholderPresenting

extension PaymentMethodsViewController: PlaceholderPresenting {
    func showPlaceholder() {
        tableView.isHidden = true

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
        tableView.isHidden = false
        scrollView.removeFromSuperview()
    }
}

// MARK: - Localized

private extension PaymentMethodsViewController {
    enum Localized {
        static let paymentMethods = NSLocalizedString(
            "PaymentMethods.paymentMethods",
            bundle: Bundle.framework,
            value: "Способ оплаты",
            comment: "Title `Способ оплаты` на экране выбора способа оплаты https://yadi.sk/i/0dSpSggROTC0Jw"
        )
        static let unbindCard = NSLocalizedString(
            "PaymentMethods.unbindCard",
            bundle: Bundle.framework,
            value: "Отвязать",
            comment: "Текст кнопки отвязать <screenshot>"
        )
    }

    enum Resources {
        static let kassaLogo = UIImage.localizedImage("image.logo")
    }
}

// MARK: - Constants

private extension PaymentMethodsViewController {
    enum Constants {
        static let estimatedRowHeight: CGFloat = 72
        static let defaultTableViewHeight: CGFloat = 395
        static let navigationBarHeight: CGFloat = 44
    }
}
