import UIKit

protocol AttachedCardCountViewControllerDelegate: AnyObject {
    func attachedCardCountViewController(
        _ attachedCardCountViewController: AttachedCardCountViewController,
        didSaveCardCount cardCount: Int?
    )
}

final class AttachedCardCountViewController: UIViewController {

    public static func makeModule(
        cardCount: Int?,
        delegate: AttachedCardCountViewControllerDelegate? = nil
    ) -> UIViewController {
        let controller = AttachedCardCountViewController()
        controller.delegate = delegate
        controller.initialCardCount = cardCount
        return controller
    }

    weak var delegate: AttachedCardCountViewControllerDelegate?

    private let cards = Array(0...5)

    // MARK: - Initial values

    private var initialCardCount: Int?

    // MARK: - UI properties

    fileprivate lazy var countPickerView: UIPickerView = {
        $0.dataSource = self
        $0.delegate = self
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setStyles(UIPickerView.Styles.defaultBackground)
        $0.selectRow(initialCardCount ?? 0, inComponent: 0, animated: false)
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
        let cardCount = countPickerView.selectedRow(inComponent: 0)
        delegate?.attachedCardCountViewController(
            self,
            didSaveCardCount: cardCount == 0 ? nil : cardCount
        )
        navigationController?.popViewController(animated: true)
    }
}

extension AttachedCardCountViewController: UIPickerViewDelegate {
    func pickerView(
        _ pickerView: UIPickerView,
        titleForRow row: Int,
        forComponent component: Int
    ) -> String? {
        return cards[row] == 0 ? translate(CommonLocalized.none) : String(cards[row])
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

extension AttachedCardCountViewController: UIPickerViewDataSource {

    public func numberOfComponents(
        in pickerView: UIPickerView
    ) -> Int {
        return 1
    }

    public func pickerView(
        _ pickerView: UIPickerView,
        numberOfRowsInComponent component: Int
    ) -> Int {
        return cards.count
    }
}

private extension AttachedCardCountViewController {
    enum Localized: String {
        case title = "cards.title"
    }
}
