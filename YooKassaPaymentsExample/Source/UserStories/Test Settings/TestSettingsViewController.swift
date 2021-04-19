import UIKit
import YooKassaPayments

protocol TestSettingsViewControllerDelegate: class {
    func testSettingsViewController(
        _ testSettingsViewController: TestSettingsViewController,
        didChangeSettings settings: TestSettings
    )
}

final class TestSettingsViewController: UIViewController {

    public static func makeModule(
        settings: TestSettings,
        delegate: TestSettingsViewControllerDelegate? = nil
    ) -> UIViewController {
        let controller = TestSettingsViewController(settings: settings)
        controller.delegate = delegate
        return controller
    }

    weak var delegate: TestSettingsViewControllerDelegate?

    // MARK: - UI properties

    private lazy var tableViewController = TableViewController(style: .grouped)
    
    private lazy var closeBarItem = UIBarButtonItem(
        image: #imageLiteral(resourceName: "Settings.Close"),
        style: .plain,
        target: self,
        action: #selector(closeBarButtonItemDidPress)
    )
    
    private lazy var testModeCell = switchCellWith(
        title: translate(Localized.title),
        initialValue: { $0.isTestModeEnadled },
        settingHandler: { $0.isTestModeEnadled = $1 }
    )

    // MARK: - Private properties

    private var settings: TestSettings {
        willSet {
            needUpdateTable = newValue.isTestModeEnadled != settings.isTestModeEnadled
        }
        didSet {
            if needUpdateTable {
                updateSections(for: settings.isTestModeEnadled)
                tableViewController.reload()
            }
            delegate?.testSettingsViewController(self, didChangeSettings: settings)
        }
    }

    private var needUpdateTable: Bool = false

    // MARK: - Managing the View

    override func loadView() {
        view = UIView()

        view.setStyles(UIView.Styles.grayBackground)

        let tableView: UITableView = tableViewController.tableView
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        let constraints: [NSLayoutConstraint]

        if #available(iOS 11.0, *) {
            constraints = [
                tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
                view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: tableView.bottomAnchor),
            ]
        } else {
            constraints = [
                tableView.top.constraint(equalTo: view.top),
                tableView.leading.constraint(equalTo: view.leading),
                view.trailing.constraint(equalTo: tableView.trailing),
                view.bottom.constraint(equalTo: tableView.bottom),
            ]
        }

        NSLayoutConstraint.activate(constraints)

        tableViewController.didMove(toParent: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(hideKeyboard)
        )
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        navigationItem.leftBarButtonItem = closeBarItem
        navigationItem.title = translate(Localized.title)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        updateSections(for: settings.isTestModeEnadled)
        tableViewController.reload(force: true)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    // MARK: - Initialization/Deinitialization

    init(settings: TestSettings) {
        self.settings = settings

        super.init(nibName: nil, bundle: nil)

        addChild(tableViewController)
    }

    @available(*, unavailable, message: "Use init(settings:) instead")
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("Use init(settings:) instead of init(nibName:, bundle:)")
    }

    @available(*, unavailable, message: "Use init(settings:) instead")
    required init?(coder aDecoder: NSCoder) {
        fatalError("Use init(settings:) instead of init?(coder:)")
    }

    // MARK: - Action handlers
    
    @objc
    private func hideKeyboard(
        _ gestureRecognizer: UITapGestureRecognizer
    ) {
        view.endEditing(true)
    }

    @objc
    private func closeBarButtonItemDidPress() {
        navigationController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    @objc
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            tableViewController.tableView.contentInset.bottom = keyboardSize.height
        }
    }

    @objc
    func keyboardWillHide(notification: NSNotification) {
        tableViewController.tableView.contentInset.bottom = 0
    }
}

// MARK: - TableView data

extension TestSettingsViewController {

    private func updateSections(for testModeEnabled: Bool) {
        if testModeEnabled {
            tableViewController.sections = [
                testModeSection,
                testModeOptionsSection,
                processOptionsSection,
            ]
        } else {
            tableViewController.sections = [testModeSection]
        }
    }

    private var testModeSection: SectionDescriptor {
        return SectionDescriptor(rows: [testModeCell])
    }

    private var testModeOptionsSection: SectionDescriptor {
        let paymentAuthCell = switchCellWith(
            title: translate(Localized.paymentAuth),
            initialValue: { $0.isPaymentAuthorizationPassed },
            settingHandler: { $0.isPaymentAuthorizationPassed = $1 }
        )
        
        let paymentErrorCell = switchCellWith(
            title: translate(Localized.paymentError),
            initialValue: { $0.isPaymentWithError },
            settingHandler: { $0.isPaymentWithError = $1 }
        )

        let cards = CellDescriptor(configuration: { [unowned self] (cell: ContainerTableViewCell<TextValueView>) in
            cell.containedView.title = translate(Localized.attached)
            cell.containedView.value = self.settings.cardsCount.flatMap(String.init) ?? translate(CommonLocalized.none)
            cell.accessoryType = .disclosureIndicator
        }, selection: { [unowned self] (indexPath) in
            self.tableViewController.tableView.deselectRow(at: indexPath, animated: true)
            
            let controller = AttachedCardCountViewController.makeModule(
                cardCount: self.settings.cardsCount,
                delegate: self
            )
            self.navigationController?.pushViewController(
                controller,
                animated: true
            )
        })

        return SectionDescriptor(rows: [
            paymentAuthCell,
            cards,
            paymentErrorCell,
        ])
    }
    
    private var processOptionsSection: SectionDescriptor {
        var rows: [CellDescriptor] = []
        
        rows.append(CellDescriptor(configuration: {
            [unowned self] (cell: ContainerTableViewCell<TextValueView>) in
            cell.containedView.title = translate(Localized.processType)
            cell.containedView.value = self.settings.processConfirmation?.description
                ?? translate(CommonLocalized.none)
            cell.accessoryType = .disclosureIndicator
        }, selection: { [unowned self] (indexPath) in
            self.tableViewController.tableView.deselectRow(at: indexPath, animated: true)
            
            let controller = ProcessViewController.makeModule(
                processConfirmation: self.settings.processConfirmation,
                delegate: self
            )
            self.navigationController?.pushViewController(
                controller,
                animated: true
            )
        }))
        
        if let processConfirmation = settings.processConfirmation {
            rows.append(CellDescriptor(configuration: {
                [unowned self] (cell: ContainerTableViewCell<TextFieldView>) in
                cell.containedView.placeholder = processConfirmation.description
                cell.containedView.text = processConfirmation.url
                cell.containedView.valueChangeHandler = {
                    switch processConfirmation {
                    case .threeDSecure:
                        self.settings.processConfirmation = .threeDSecure($0 ?? "")
                        
                    case .app2app:
                        self.settings.processConfirmation = .app2app($0 ?? "")
                    }
                }
            }))
        }

        return SectionDescriptor(rows: rows)
    }

    private func switchCellWith(
        title: String,
        initialValue: @escaping (TestSettings) -> Bool,
        settingHandler: @escaping (inout TestSettings, Bool) -> Void
    ) -> CellDescriptor {
        return CellDescriptor(configuration: { [unowned self] (cell: ContainerTableViewCell<TitledSwitchView>) in
            cell.containedView.title = title
            cell.containedView.isOn = initialValue(self.settings)
            cell.containedView.valueChangeHandler = {
                settingHandler(&self.settings, $0)
            }
        })
    }
}

// MARK: - AttachedCardCountViewControllerDelegate

extension TestSettingsViewController: AttachedCardCountViewControllerDelegate {
    func attachedCardCountViewController(
        _ attachedCardCountViewController: AttachedCardCountViewController,
        didSaveCardCount сardCount: Int?
    ) {
        settings.cardsCount = сardCount
        tableViewController.reloadTable()
    }
}

// MARK: - ProcessViewControllerDelegate

extension TestSettingsViewController: ProcessViewControllerDelegate {
    func processViewController(
        _ processViewController: ProcessViewController,
        processConfirmation: ProcessConfirmation?
    ) {
        settings.processConfirmation = processConfirmation
        updateSections(for: settings.isTestModeEnadled)
        tableViewController.reloadTable()
    }
}

// MARK: - Localization

extension TestSettingsViewController {
    private enum Localized: String {
        case title = "test_mode.title"
        case paymentAuth = "test_mode.payment_auth"
        case attached = "test_mode.attached_cards"
        case paymentError = "test_mode.payment_error"
        case processType = "test_mode.process_type"
    }
}
