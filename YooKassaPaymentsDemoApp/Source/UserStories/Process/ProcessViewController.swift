import UIKit

protocol ProcessViewControllerDelegate: AnyObject {
    func processViewController(
        _ processViewController: ProcessViewController,
        processConfirmation: ProcessConfirmation?
    )
}

final class ProcessViewController: UIViewController {
    public static func makeModule(
        processConfirmation: ProcessConfirmation?,
        delegate: ProcessViewControllerDelegate? = nil
    ) -> UIViewController {
        let controller = ProcessViewController()
        controller.delegate = delegate
        controller.initialProcessConfirmation = processConfirmation
        return controller
    }

    weak var delegate: ProcessViewControllerDelegate?

    private let processesConfirmation = ProcessConfirmation.allCasesWithNil

    // MARK: - Initial values

    private var initialProcessConfirmation: ProcessConfirmation?

    // MARK: - UI properties

    fileprivate lazy var countPickerView: UIPickerView = {
        $0.dataSource = self
        $0.delegate = self
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setStyles(UIPickerView.Styles.defaultBackground)
        $0.selectRow(
            processesConfirmation.firstIndex(where: {
                switch ($0, initialProcessConfirmation) {
                case (.threeDSecure, .threeDSecure): return true
                case (.app2app, .app2app): return true
                default: return false
                }
            }) ?? 0,
            inComponent: 0,
            animated: false
        )
        return $0
    }(UIPickerView())

    fileprivate lazy var saveBarItem = UIBarButtonItem(
        title: translate(CommonLocalized.save),
        style: .plain,
        target: self,
        action: #selector(saveButtonDidPress)
    )

    // MARK: - Managing the View

    override func loadView() {
        view = UIView()
        view.setStyles(UIView.Styles.grayBackground)
        navigationItem.title = translate(Localized.title)

        loadSubviews()
        loadConstraints()
    }

    private func loadSubviews() {
        view.addSubview(countPickerView)
        navigationItem.rightBarButtonItem = saveBarItem
    }

    private func loadConstraints() {
        let constraints = [
            countPickerView.leading.constraint(equalTo: view.leading),
            topLayoutGuide.bottom.constraint(equalTo: countPickerView.top),
            countPickerView.trailing.constraint(equalTo: view.trailing),
            countPickerView.height.constraint(equalToConstant: 154),
        ]

        NSLayoutConstraint.activate(constraints)
    }

    // MARK: - Actions

    @objc
    private func saveButtonDidPress() {
        let selectedRow = countPickerView.selectedRow(inComponent: 0)
        delegate?.processViewController(
            self,
            processConfirmation: processesConfirmation[selectedRow]
        )
        navigationController?.popViewController(animated: true)
    }
}

extension ProcessViewController: UIPickerViewDelegate {
    func pickerView(
        _ pickerView: UIPickerView,
        titleForRow row: Int,
        forComponent component: Int
    ) -> String? {
        return processesConfirmation[row]?.description
            ?? translate(CommonLocalized.none)
    }

    func pickerView(
        _ pickerView: UIPickerView,
        rowHeightForComponent component: Int
    ) -> CGFloat {
        return Space.quadruple
    }

    public func pickerView(
        _ pickerView: UIPickerView,
        didSelectRow row: Int,
        inComponent component: Int
    ) {}
}

extension ProcessViewController: UIPickerViewDataSource {

    public func numberOfComponents(
        in pickerView: UIPickerView
    ) -> Int {
        return 1
    }

    public func pickerView(
        _ pickerView: UIPickerView,
        numberOfRowsInComponent component: Int
    ) -> Int {
        return processesConfirmation.count
    }
}

private extension ProcessViewController {
    enum Localized: String {
        case title = "process.title"
    }
}
