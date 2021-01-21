import UIKit

final class PaymentMethodsViewController: UIViewController, PlaceholderProvider {

    // MARK: - VIPER

    var output: PaymentMethodsViewOutput!

    // MARK: - UI properties

    private lazy var blurEffectStyle: UIBlurEffect.Style = {
        let style: UIBlurEffect.Style
        if #available(iOS 13.0, *) {
            style = .systemUltraThinMaterial
        } else {
            style = .light
        }
        return style
    }()

    fileprivate lazy var titleView: UIVisualEffectView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIVisualEffectView(effect: UIBlurEffect(style: blurEffectStyle)))

    fileprivate lazy var headerView: ActionSheetHeaderView = {
        $0.title = §Localized.paymentMethods
        $0.backgroundColor = .clear
        $0.setContentHuggingPriority(.fittingSizeLevel, for: .vertical)
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(ActionSheetHeaderView())

    fileprivate lazy var separatorView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setStyles(UIView.Styles.separator)
        return $0
    }(UIView())

    fileprivate var tableView: UITableView {
        return tableViewController.tableView
    }

    private let tableViewController = UITableViewController(style: .plain)

    fileprivate var activityIndicatorView: UIView?

    fileprivate lazy var scrollView = UIScrollView()
    fileprivate lazy var contentView = UIView()

    // MARK: - PlaceholderProvider

    fileprivate var shouldDefaultTableViewHeight = true

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

    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        addChild(tableViewController)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addChild(tableViewController)
    }

    // MARK: - Managing the view

    override func loadView() {
        view = UIView()
        view.preservesSuperviewLayoutMargins = true
        view.backgroundColor = .clear
        loadSubviews()
        loadConstraints()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        output.setupView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        output.viewDidAppear()
    }

    private func loadSubviews() {
        titleView.contentView.addSubview(headerView)

        [
            tableView,
            separatorView,
            titleView,
        ].forEach(view.addSubview)
        tableViewController.didMove(toParent: self)
        setupTableView()
    }

    private func loadConstraints() {
        let views: [String: UIView] = [
            "titleView": titleView,
            "tableView": tableView,
            "headerView": headerView,
            "separatorView": separatorView,
        ]

        let formats = [
            "V:|[titleView][separatorView]",
            "V:|[tableView]|",
            "V:|[headerView]|",
        ]

        var constraints = formats.flatMap {
            NSLayoutConstraint.constraints(
                withVisualFormat: $0,
                options: [],
                metrics: nil,
                views: views
            )
        }

        func makeFullwidthConstraints(view: UIView) -> [NSLayoutConstraint] {
            return [
                view.superview?.leading.constraint(equalTo: view.leading),
                view.superview?.trailing.constraint(equalTo: view.trailing),
            ].compactMap { $0 }
        }

        constraints += views.values.flatMap(makeFullwidthConstraints)

        NSLayoutConstraint.activate(constraints)
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.estimatedRowHeight = 69
        tableView.rowHeight = UITableView.automaticDimension
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.appendStyle(UIView.Styles.grayBackground)
        tableView.register(IconButtonItemTableViewCell.self)
        tableView.register(LargeIconButtonItemViewCell.self)

        if #available(iOS 13.0, *) {
            tableView.separatorColor = .separator
        } else {
            tableView.separatorColor = .alto
        }
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
            return tableViewHeightConstraint
        }

        tableView.contentInset.top = separatorView.frame.maxY
        tableView.scrollIndicatorInsets.top = separatorView.frame.maxY

        let contentEffectiveHeight = tableView.contentSize.height
            + tableView.contentInset.top
            + tableView.contentInset.bottom
            + UIScreen.safeAreaInsets.bottom

        let needUpdate: Bool
        let newValue = viewModels.isEmpty || shouldDefaultTableViewHeight
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
                self.view.superview?.superview?.layoutIfNeeded()
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

        if let balanceText = item.balanceText {
            let largeCell = tableView.dequeueReusableCell(
                withType: LargeIconButtonItemViewCell.self,
                for: indexPath
            )
            largeCell.icon = item.image
            largeCell.leftButtonTitle = item.name
            largeCell.title = balanceText

            largeCell.leftButtonPressHandler = { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.output.logoutDidPress(at: indexPath)
            }

            cell = largeCell
        } else {
            let smallCell = tableView.dequeueReusableCell(
                withType: IconButtonItemTableViewCell.self,
                for: indexPath
            )
            smallCell.title = item.name
            smallCell.icon = item.image

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
        shouldDefaultTableViewHeight = true

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
        shouldDefaultTableViewHeight = false

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
        shouldDefaultTableViewHeight = true

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
        shouldDefaultTableViewHeight = false
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
        static let defaultTableViewHeight: CGFloat = 300
    }
}
