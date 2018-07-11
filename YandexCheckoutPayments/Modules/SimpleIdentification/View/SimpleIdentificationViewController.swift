import Foundation
import UIKit

final class SimpleIdentificationViewController: UIViewController {

    // MARK: - VIPER module properties

    var output: SimpleIdentificationViewOutput!

    // MARK: - Data

    fileprivate var displayItems: [ShowcaseDisplayItem] = []
    fileprivate var currentSelectIndex: Int?

    // MARK: - Subviews properties

    fileprivate lazy var submitButton: UIButton = {
        $0.setStyles(UIButton.DynamicStyle.primary)
        $0.addTarget(self, action: #selector(submitDidPress), for: .touchUpInside)
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIButton(type: .custom))

    fileprivate var tableView: UITableView {
        return tableViewController.tableView
    }

    private let tableViewController = UITableViewController(style: .plain)

    private lazy var closeBarItem = UIBarButtonItem(image: #imageLiteral(resourceName: "Settings.Close"),
                                                    style: .plain,
                                                    target: self,
                                                    action: #selector(closeDidPress))

    private var submitButtonBottomConstraint: NSLayoutConstraint!

    // MARK: - Initializers

    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        addChildViewController(tableViewController)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addChildViewController(tableViewController)
    }

    // MARK: - Managing the View

    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor.white
        navigationItem.leftBarButtonItem = closeBarItem
        loadSubviews()
        loadConstraints()
        setupTableView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        output.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startKeyboardObserving()
    }

    override func viewWillDisappear(_ animated: Bool) {
        stopKeyboardObserving()
        super.viewWillDisappear(animated)
    }

    private func loadSubviews() {
        view.addSubview(tableView)
        view.addSubview(submitButton)
        tableViewController.didMove(toParentViewController: self)
    }

    private func loadConstraints() {
        let constraints: [NSLayoutConstraint]

        if #available(iOS 11.0, *) {
            submitButtonBottomConstraint =
                view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: submitButton.bottomAnchor,
                                                                constant: Space.double)
            constraints = [
                tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),

                submitButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                      constant: Space.double),
                submitButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: Space.single),
                view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: submitButton.trailingAnchor,
                                                                   constant: Space.double),
                submitButtonBottomConstraint,
            ]
        } else {
            submitButtonBottomConstraint = view.bottom.constraint(equalTo: submitButton.bottom, constant: Space.double)
            constraints = [
                tableView.top.constraint(equalTo: view.top),
                tableView.leading.constraint(equalTo: view.leading),
                view.trailing.constraint(equalTo: tableView.trailing),

                submitButton.leading.constraint(equalTo: view.leading, constant: Space.double),
                submitButton.top.constraint(equalTo: tableView.bottom, constant: Space.single),
                view.trailing.constraint(equalTo: submitButton.trailing, constant: Space.double),
                submitButtonBottomConstraint,
            ]
        }

        NSLayoutConstraint.activate(constraints)
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.estimatedRowHeight = 70
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.register(TextInputTableViewCell.self)
        tableView.register(TextTableViewCell.self)
        tableView.register(SelectTableViewCell.self)
    }

    // MARK: - Actions

    @objc
    private func closeDidPress() {
        output.closeDidPress()
    }

    @objc
    private func submitDidPress() {
        output.submitDidPress()
    }
}

extension SimpleIdentificationViewController: KeyboardObserver {
    func keyboardWillShow(with keyboardInfo: KeyboardNotificationInfo) {
        updateSubmitButtonBottomConstraint(keyboardInfo: keyboardInfo)
    }

    func keyboardDidShow(with keyboardInfo: KeyboardNotificationInfo) {}

    func keyboardWillHide(with keyboardInfo: KeyboardNotificationInfo) {
        updateSubmitButtonBottomConstraint(keyboardInfo: keyboardInfo)
    }

    func keyboardDidHide(with keyboardInfo: KeyboardNotificationInfo) {}
    func keyboardDidUpdateFrame(_ keyboardFrame: CGRect) {}

    private func updateSubmitButtonBottomConstraint(keyboardInfo: KeyboardNotificationInfo) {
        let offset = keyboardYOffset(from: keyboardInfo.endKeyboardFrame) ?? 0

        view.layoutIfNeeded()
        UIView.animate(withDuration: CATransaction.animationDuration()) {
            self.submitButtonBottomConstraint.constant = Space.double + offset
            self.view.layoutIfNeeded()
        }
    }
}

extension SimpleIdentificationViewController: SimpleIdentificationViewInput {

    func updateDisplayItem(_ item: ShowcaseDisplayItem, at index: Int) {
        displayItems[index] = item
        let indexPath = IndexPath(row: index, section: 0)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    func setTitle(_ title: String) {
        navigationItem.title = title
    }

    func setDisplayItems(_ items: [ShowcaseDisplayItem]) {
        displayItems = items
        tableView.reloadData()
    }

    func setSubmitItem(_ item: SubmitDisplayItem) {
        submitButton.setStyledTitle(item.title, for: .normal)
        submitButton.isEnabled = item.isEnabled
    }

    func showError(_ error: String) {
        let alertController = UIAlertController(title: "УИ",
                                                message: error,
                                                preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
}

extension SimpleIdentificationViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = displayItems[indexPath.row]
        return ShowcaseCellModuleFactory.makeShowcaseCellModuleForm(item,
                                                                    in: tableView,
                                                                    moduleOutput: self)
    }
}

extension SimpleIdentificationViewController: UITableViewDelegate {

}

extension SimpleIdentificationViewController: TextInputTableViewCellModuleOutput {

    func needLayoutUpdate() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }

    func textInput(cell: UITableViewCell, didChangeText text: String, valid: Bool) {
        if let indexPath = tableView.indexPath(for: cell) {
            displayItems[indexPath.row].value = text
            output.changedInputText(text, valid: valid, at: indexPath.row)
        }
    }
}

extension SimpleIdentificationViewController: SelectTableViewCellModuleOutput {

    func didPressSelect(cell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell),
        case .select(let item, let option) = displayItems[indexPath.row] else { return }

        currentSelectIndex = indexPath.row
        let select = SelectOptionModuleAssembly.makeModule(item: item,
                                                           selectOption: option,
                                                           moduleOutput: self)
        present(select, animated: true, completion: nil)
    }
}

extension SimpleIdentificationViewController: SelectOptionModuleOutput {

    func didFinish() {
        dismiss(animated: true, completion: nil)
    }

    func didFinish(with option: SelectOptionDisplayItem) {
        dismiss(animated: true, completion: nil)
        if let index = currentSelectIndex {
            output.selectOption(option, at: index)
        }
    }
}
