import UIKit

protocol SettingsViewControllerDelegate: class {
    func settingsViewController(_ settingsViewController: SettingsViewController,
                                didChangeSettings settings: Settings)
}

final class SettingsViewController: UIViewController {

    public static func makeModule(settings: Settings,
                                  delegate: SettingsViewControllerDelegate? = nil) -> UIViewController {

        let controller = SettingsViewController(settings: settings)
        controller.delegate = delegate

        return controller
    }

    weak var delegate: SettingsViewControllerDelegate?

    // MARK: - UI properties

    private lazy var tableViewController = TableViewController(style: .grouped)

    private lazy var closeBarItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Settings.Close"),
                                                    style: .plain,
                                                    target: self,
                                                    action: #selector(closeBarButtonItemDidPress))

    // MARK: - Private properties

    private var settings: Settings {
        didSet {
            delegate?.settingsViewController(self, didChangeSettings: settings)
        }
    }

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

        tableViewController.didMove(toParentViewController: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = closeBarItem
        navigationItem.title = Localized.title
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        tableViewController.sections = sectionDescriptors
        tableViewController.reload()
    }

    // MARK: - Initialization/Deinitialization

    init(settings: Settings) {
        self.settings = settings

        super.init(nibName: nil, bundle: nil)

        addChildViewController(tableViewController)
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

extension SettingsViewController {

    private var sectionDescriptors: [SectionDescriptor] {
        return [
            paymentMethodsSection,
            uiCustomizationSection,
            testModeSection,
        ]
    }

    private var paymentMethodsSection: SectionDescriptor {
        let yandexMoneyCell = switchCellWith(title: Localized.yandexMoney,
                                             initialValue: { $0.isYandexMoneyEnabled },
                                             settingHandler: { $0.isYandexMoneyEnabled = $1 })

        let sberbankCell = switchCellWith(title: Localized.sberbank,
                                          initialValue: { $0.isSberbankEnabled },
                                          settingHandler: { $0.isSberbankEnabled = $1 })

        let bankCardCell = switchCellWith(title: Localized.bankCard,
                                          initialValue: { $0.isBankCardEnabled },
                                          settingHandler: { $0.isBankCardEnabled = $1 })

        let applePayCell = switchCellWith(title: Localized.applePay,
                                          initialValue: { $0.isApplePayEnabled },
                                          settingHandler: { $0.isApplePayEnabled = $1 })

        return SectionDescriptor(headerText: Localized.paymentMethods,
                                 rows: [yandexMoneyCell, sberbankCell, bankCardCell, applePayCell])
    }

    private var uiCustomizationSection: SectionDescriptor {
        let yandexLogoCell = switchCellWith(title: Localized.yandexLogo,
                                            initialValue: { $0.isShowingYandexLogoEnabled },
                                            settingHandler: { $0.isShowingYandexLogoEnabled = $1 })

        return SectionDescriptor(rows: [yandexLogoCell])
    }

    private var testModeSection: SectionDescriptor {
        let testMode = CellDescriptor(configuration: { [unowned self] (cell: ContainerTableViewCell<TextValueView>) in

            cell.containedView.title = Localized.test_mode
            cell.containedView.value = self.settings.testModeSettings.isTestModeEnadled ?
                translate(CommonLocalized.on) : translate(CommonLocalized.off)
            cell.accessoryType = .disclosureIndicator
        }, selection: { [unowned self] (indexPath) in

            self.tableViewController.tableView.deselectRow(at: indexPath, animated: true)

            let controller = TestSettingsViewController.makeModule(settings: self.settings.testModeSettings,
                                                                   delegate: self)
            let navigation = UINavigationController(rootViewController: controller)

            if #available(iOS 11.0, *) {
                navigation.navigationBar.prefersLargeTitles = true
            }

            navigation.modalPresentationStyle = .formSheet

            self.present(navigation, animated: true, completion: nil)
        })

        return SectionDescriptor(rows: [testMode])
    }

    private func switchCellWith(title: String,
                                initialValue: @escaping (Settings) -> Bool,
                                settingHandler: @escaping (inout Settings, Bool) -> Void)
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

// MARK: - TestSettingsViewControllerDelegate

extension SettingsViewController: TestSettingsViewControllerDelegate {
    func testSettingsViewController(_ testSettingsViewController: TestSettingsViewController,
                                    didChangeSettings settings: TestSettings) {

        self.settings.testModeSettings = settings
        tableViewController.reloadTable()
    }
}

// MARK: - Localization

extension SettingsViewController {

    private enum Localized {
        static let title = NSLocalizedString("settings.title", comment: "")

        static let paymentMethods = NSLocalizedString("settings.payment_methods.title", comment: "")

        static let yandexMoney = NSLocalizedString("settings.payment_methods.yandex_money", comment: "")
        static let bankCard = NSLocalizedString("settings.payment_methods.bank_card", comment: "")
        static let sberbank = NSLocalizedString("settings.payment_methods.sberbank", comment: "")
        static let applePay = NSLocalizedString("settings.payment_methods.apple_pay", comment: "")

        static let yandexLogo = NSLocalizedString("settings.ui_customization.yandex_logo", comment: "")

        static let test_mode = NSLocalizedString("settings.test_mode.title", comment: "")
    }

}
