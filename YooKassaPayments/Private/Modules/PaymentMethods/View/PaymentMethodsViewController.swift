import UIKit

final class PaymentMethodsViewController: UIViewController, PlaceholderProvider {

    // MARK: - VIPER

    var output: PaymentMethodsViewOutput!

    // MARK: - UI properties

    fileprivate lazy var titleView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIView())

    fileprivate lazy var headerView: ActionSheetHeaderView = {
        $0.title = §Localized.paymentMethods
        $0.setStyles(UIView.Styles.defaultBackground)
        $0.setContentHuggingPriority(.fittingSizeLevel, for: .vertical)
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(ActionSheetHeaderView())

    fileprivate lazy var tableView: UITableView = {
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

    fileprivate var activityIndicatorView: UIView?

    fileprivate lazy var scrollView = UIScrollView()
    fileprivate lazy var contentView = UIView()

    // MARK: - PlaceholderProvider

    lazy var placeholderView: PlaceholderView = {
        $0.setStyles(UIView.Styles.defaultBackground)
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentView = self.actionTextDialog
        return $0
    }(PlaceholderView())

    lazy var actionTextDialog: ActionTextDialog = {
        $0.setStyles(ActionTextDialog.Styles.fail, ActionTextDialog.Styles.light)
        return $0
    }(ActionTextDialog())

    // MARK: - Constraints

    private var tableViewHeightConstraint: NSLayoutConstraint?

    // MARK: - Data

    fileprivate var viewModels: [PaymentMethodViewModel] = []

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
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        output.viewDidAppear()
    }

    private func setupView() {
        titleView.addSubview(headerView)

        [
            tableView,
            titleView,
        ].forEach(view.addSubview)
    }

    private func setupConstraints() {
        let titleViewTopConstraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
            titleViewTopConstraint = titleView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        } else {
            titleViewTopConstraint = titleView.topAnchor.constraint(equalTo: topLayoutGuide.topAnchor)
        }

        let constraints = [
            headerView.topAnchor.constraint(equalTo: titleView.topAnchor),
            headerView.bottomAnchor.constraint(equalTo: titleView.bottomAnchor),
            headerView.leadingAnchor.constraint(equalTo: titleView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: titleView.trailingAnchor),

            titleViewTopConstraint,
            titleView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            tableView.topAnchor.constraint(equalTo: titleView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ]

        NSLayoutConstraint.activate(constraints)
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

        let contentEffectiveHeight = CGFloat(viewModels.count) * Constants.estimatedRowHeight
            + tableView.contentInset.top
            + tableView.contentInset.bottom
            + UIScreen.safeAreaInsets.bottom

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
        return viewModels.count
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
        return UITableView.automaticDimension
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
        headerView.logo = isVisible ? Resources.kassaLogo : nil
    }

    func setPaymentMethodViewModels(_ models: [PaymentMethodViewModel]) {
        viewModels = models
        tableView.reloadData()
    }

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
        actionTextDialog.title = message
        showPlaceholder()
    }

    func setPlaceholderViewButtonTitle(_ title: String) {
        actionTextDialog.buttonTitle = title
    }
}

// MARK: - PlaceholderPresenting

extension PaymentMethodsViewController: PlaceholderPresenting {
    func showPlaceholder() {
        titleView.isHidden = true
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
        titleView.isHidden = false
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
            case buttonTitle = "Common.PlaceholderView.buttonTitle"
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
        static let defaultTableViewHeight: CGFloat = 300
    }
}
