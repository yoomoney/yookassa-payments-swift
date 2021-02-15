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
        $0.text = §Localized.PlaceholderView.text
        $0.delegate = output
        return $0
    }(ActionTitleTextDialog())

    // MARK: - Constraints

    private var tableViewHeightConstraint: NSLayoutConstraint?

    // MARK: - Data

    private var viewModels: [PaymentMethodViewModel] = []

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
        leftItem.setStyles(UILabel.DynamicStyle.headline2)
        leftItem.text = §Localized.paymentMethods
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftItem)
    }

    // MARK: - Configuring the View’s Layout Behavior

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async {
            self.fixTableViewHeight()
        }
    }

    private func fixTableViewHeight() {
        var constraint: NSLayoutConstraint! {
            tableViewHeightConstraint
        }

        let contentEffectiveHeight = tableView.contentSize.height
            + tableView.contentInset.top
            + tableView.contentInset.bottom
            + UIScreen.safeAreaInsets.bottom
            + Constants.navigationBarHeight

        let needUpdate: Bool
        let newValue = viewModels.isEmpty
            ? Constants.defaultTableViewHeight
            : contentEffectiveHeight

        if tableViewHeightConstraint == nil {
            tableViewHeightConstraint = NSLayoutConstraint(
                item: tableView,
                attribute: .height,
                relatedBy: .equal,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1,
                constant: newValue
            )
            constraint.priority = .defaultHigh
            constraint.isActive = true
            needUpdate = true
        } else if constraint.constant != newValue {
            constraint.constant = newValue
            needUpdate = true
        } else {
            needUpdate = false
        }

        if needUpdate {
            UIView.animate(withDuration: 0.4) {
                self.view.superview?.superview?.superview?.layoutIfNeeded()
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension PaymentMethodsViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        viewModels.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let item = viewModels[indexPath.row]

        let cell: UITableViewCell

        if let subtitle = item.subtitle {
            let largeCell = tableView.dequeueReusableCell(
                withType: LargeIconButtonItemViewCell.self,
                for: indexPath
            )
            largeCell.icon = item.image
            largeCell.title = item.title
            largeCell.subtitle = subtitle

            cell = largeCell
        } else {
            let smallCell = tableView.dequeueReusableCell(
                withType: IconButtonItemTableViewCell.self,
                for: indexPath
            )
            smallCell.icon = item.image
            smallCell.title = item.title

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
        guard indexPath.row < viewModels.count else { return }
        output.didSelectViewModel(viewModels[indexPath.row], at: indexPath)
    }
}

// MARK: - PaymentMethodsViewInput

extension PaymentMethodsViewController: PaymentMethodsViewInput {
    func setLogoVisible(_ isVisible: Bool) {
        guard isVisible else {
            navigationItem.rightBarButtonItem = nil
            return
        }
        let image = UIImageView(image: Resources.kassaLogo)
        let rightItem = UIBarButtonItem(customView: image)
        navigationItem.rightBarButtonItem = rightItem
    }

    func setPaymentMethodViewModels(_ models: [PaymentMethodViewModel]) {
        viewModels = models
        tableView.reloadData()
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

    func setPlaceholderViewButtonTitle(_ title: String) {
        actionTitleTextDialog.buttonTitle = title
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
    enum Localized: String {
        case paymentMethods = "PaymentMethods.paymentMethods"
        case logoImage = "image.logo"

        enum PlaceholderView: String {
            case text = "Common.PlaceholderView.text"
        }
    }

    enum Resources {
        static let kassaLogo = UIImage.named(§Localized.logoImage)
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
