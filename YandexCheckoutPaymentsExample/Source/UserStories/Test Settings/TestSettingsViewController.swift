import UIKit
import YandexCheckoutPayments

protocol TestSettingsViewControllerDelegate: class {
    func testSettingsViewController(_ testSettingsViewController: TestSettingsViewController,
                                    didChangeSettings settings: TestSettings)
}

final class TestSettingsViewController: UIViewController {

    public static func makeModule(settings: TestSettings,
                                  delegate: TestSettingsViewControllerDelegate? = nil) -> UIViewController {

        let controller = TestSettingsViewController(settings: settings)
        controller.delegate = delegate

        return controller
    }

    weak var delegate: TestSettingsViewControllerDelegate?

    // MARK: - UI properties

    private lazy var tableViewController = TableViewController(style: .grouped)

    private lazy var closeBarItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Settings.Close"),
                                                    style: .plain,
                                                    target: self,
                                                    action: #selector(closeBarButtonItemDidPress))

    private lazy var testModeCell = switchCellWith(title: translate(Localized.title),
                                                   initialValue: { $0.isTestModeEnadled },
                                                   settingHandler: { $0.isTestModeEnadled = $1 })

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

        navigationItem.leftBarButtonItem = closeBarItem
        navigationItem.title = translate(Localized.title)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        updateSections(for: settings.isTestModeEnadled)
        tableViewController.reload(force: true)
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
    private func closeBarButtonItemDidPress() {
        navigationController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }

}

// MARK: - TableView data

extension TestSettingsViewController {

    private func updateSections(for testModeEnabled: Bool) {
        if testModeEnabled {
            tableViewController.sections = [testModeSection, testModeOptionsSection]
        } else {
            tableViewController.sections = [testModeSection]
        }
    }

    private var testModeSection: SectionDescriptor {
        return SectionDescriptor(rows: [testModeCell])
    }

    private var testModeOptionsSection: SectionDescriptor {

        // MARK: OBIOS-105 temporarily remove
//        let payment3DSCell = switchCellWith(title: translate(Localized.check3ds),
//                                            initialValue: { $0.is3DSEnabled },
//                                            settingHandler: { $0.is3DSEnabled = $1 })

        let paymentAuthCell = switchCellWith(title: translate(Localized.paymentAuth),
                                             initialValue: { $0.isPaymentAuthorizationPassed },
                                             settingHandler: { $0.isPaymentAuthorizationPassed = $1 })

        let paymentErrorCell = switchCellWith(title: translate(Localized.paymentError),
                                              initialValue: { $0.isPaymentWithError },
                                              settingHandler: { $0.isPaymentWithError = $1 })

        let cards = CellDescriptor(configuration: { [unowned self] (cell: ContainerTableViewCell<TextValueView>) in

            cell.containedView.title = translate(Localized.attached)
            cell.containedView.value = self.settings.cardsCount.flatMap(String.init) ?? translate(CommonLocalized.none)
            cell.accessoryType = .disclosureIndicator
            }, selection: { [unowned self] (indexPath) in

                self.tableViewController.tableView.deselectRow(at: indexPath, animated: true)

                let controller = AttachedCardCountViewController.makeModule(cardCount: self.settings.cardsCount,
                                                                            delegate: self)
                self.navigationController?.pushViewController(controller,
                                                              animated: true)
        })

        return SectionDescriptor(rows: [
            paymentAuthCell,
            cards,
            paymentErrorCell,
        ])
    }

    private func switchCellWith(title: String,
                                initialValue: @escaping (TestSettings) -> Bool,
                                settingHandler: @escaping (inout TestSettings, Bool) -> Void)
        -> CellDescriptor {
            return CellDescriptor(configuration: { [unowned self] (cell: ContainerTableViewCell<TitledSwitchView>) in

                cell.containedView.title = title
                cell.containedView.isOn = initialValue(self.settings)
                cell.containedView.valueChangeHandler = {
                    settingHandler(&self.settings, $0)
                }
            })
    }
}

extension TestSettingsViewController: AttachedCardCountViewControllerDelegate {
    func attachedCardCountViewController(_ attachedCardCountViewController: AttachedCardCountViewController,
                                         didSaveCardCount сardCount: Int?) {

        settings.cardsCount = сardCount
        tableViewController.reloadTable()
    }
}

// MARK: - Localization
extension TestSettingsViewController {

    private enum Localized: String {
        case title = "test_mode.title"
        case check3ds = "test_mode.3ds"
        case paymentAuth = "test_mode.payment_auth"
        case attached = "test_mode.attached_cards"
        case paymentError = "test_mode.payment_error"
    }
}
