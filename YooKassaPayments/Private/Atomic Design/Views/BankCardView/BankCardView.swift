import UIKit

protocol BankCardViewDelegate: class {
    func bankCardPanDidChange(
        _ value: String
    )
    func bankCardExpiryDateDidChange(
        _ value: String
    )
    func bankCardCvcDidChange(
        _ value: String
    )
    func scanDidPress()
    func panDidBeginEditing()
}

final class BankCardView: UIView {

    enum BankCardFocus {
        case pan
        case expiryDate
        case cvc
    }

    private enum InputState {
        case collapsed
        case uncollapsed
    }

    // MARK: - BankCardViewDelegate

    weak var delegate: BankCardViewDelegate?

    // MARK: - Public accessors

    var focus: BankCardFocus? {
        get {
            [BankCardFocus.pan, .expiryDate, .cvc].first {
                $0.field(on: self).isFirstResponder
            }
        }
        set {
            newValue?.field(on: self).becomeFirstResponder()

            switch newValue {
            case .pan?:
                setInputState(.collapsed)
            case .expiryDate?, .cvc?:
                setInputState(.uncollapsed)
            default:
                break
            }
        }
    }

    // MARK: - Pan section

    var inputPanHint: String? {
        get {
            inputPanCardView.hint
        }
        set {
            inputPanCardView.hint = newValue
        }
    }

    var inputPanLogo: UIImage? {
        get {
            inputPanCardView.logo
        }
        set {
            inputPanCardView.logo = newValue
        }
    }

    var inputPanText: String? {
        get {
            inputPanCardView.text
        }
        set {
            inputPanCardView.text = newValue
            pan = newValue ?? ""
        }
    }

    var inputPanPlaceholder: String? {
        get {
            inputPanCardView.placeholder
        }
        set {
            inputPanCardView.placeholder = newValue
        }
    }

    var inputPanRightButtonMode: InputPanCardView.RightButtonMode  {
        get {
            inputPanCardView.rightButtonMode
        }
        set {
            inputPanCardView.rightButtonMode = newValue
        }
    }

    // MARK: - Expiry date section

    var expiryDateHint: String? {
        get {
            expiryDateView.hint
        }
        set {
            expiryDateView.hint = newValue
        }
    }

    var inputExpiryDatePlaceholder: String? {
        get {
            expiryDateView.placeholder
        }
        set {
            expiryDateView.placeholder = newValue
        }
    }

    var inputExpiryDateText: String? {
        get {
            expiryDateView.text
        }
        set {
            expiryDateView.text = newValue
        }
    }

    // MARK: - CVC section

    var inputCvcHint: String? {
        get {
            inputCvcView.hint
        }
        set {
            inputCvcView.hint = newValue
        }
    }

    var inputCvcPlaceholder: String? {
        get {
            inputCvcView.placeholder
        }
        set {
            inputCvcView.placeholder = newValue
        }
    }

    // MARK: - UI properties

    private lazy var verticalStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        return view
    }()

    private lazy var horizontalStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.spacing = Space.double
        return view
    }()

    private lazy var bottomHintLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var inputPanCardView: InputPanCardView = {
        let view = InputPanCardView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()

    private lazy var expiryDateView: ExpiryDateView = {
        let view = ExpiryDateView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        view.delegate = self
        return view
    }()

    private lazy var inputCvcView: InputCvcView = {
        let view = InputCvcView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        view.delegate = self
        return view
    }()

    private lazy var spacerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    // MARK: - Stored properties

    private var pan = ""

    // MARK: - Initialization

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    // MARK: - SetupView

    private func setupView() {
        backgroundColor = .clear
        layoutMargins = UIEdgeInsets(
            top: 12,
            left: Space.double,
            bottom: 12,
            right: Space.double
        )
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        [
            verticalStackView
        ].forEach(addSubview)
        [
            horizontalStackView,
            bottomHintLabel,
        ].forEach(verticalStackView.addArrangedSubview)
        [
            inputPanCardView,
            expiryDateView,
            spacerView,
            inputCvcView,
        ].forEach(horizontalStackView.addArrangedSubview)
    }

    private func setupConstraints() {
        let constraints = [
            verticalStackView.topAnchor.constraint(
                equalTo: layoutMarginsGuide.topAnchor
            ),
            verticalStackView.bottomAnchor.constraint(
                equalTo: layoutMarginsGuide.bottomAnchor
            ),
            verticalStackView.leadingAnchor.constraint(
                equalTo: layoutMarginsGuide.leadingAnchor
            ),
            verticalStackView.trailingAnchor.constraint(
                equalTo: layoutMarginsGuide.trailingAnchor
            ),

            spacerView.widthAnchor.constraint(
                equalToConstant: Space.single
            ),

            inputPanCardView.widthAnchor.constraint(
                greaterThanOrEqualToConstant: 124
            ),
            expiryDateView.widthAnchor.constraint(
                greaterThanOrEqualToConstant: 94
            ),
            inputCvcView.widthAnchor.constraint(
                greaterThanOrEqualToConstant: 36
            ),
        ]
        NSLayoutConstraint.activate(constraints)
    }
}

// MARK: - InputPanCardViewDelegate

extension BankCardView: InputPanCardViewDelegate {
    func panDidChange(
        _ value: String
    ) {
        pan = value
        delegate?.bankCardPanDidChange(value)
    }

    func scanDidPress() {
        delegate?.scanDidPress()
    }

    func nextDidPress() {
        setInputState(.uncollapsed)
        focus = .expiryDate
    }

    func panDidBeginEditing() {
        inputPanCardView.text = pan
        delegate?.panDidBeginEditing()
        setInputState(.collapsed)
    }

    private func setInputState(
        _ state: InputState
    ) {
        switch state {
        case .collapsed:
            expiryDateView.isHidden = true
            inputCvcView.isHidden = true
            spacerView.isHidden = true
            UIView.animate(withDuration: 0.3) {
                self.expiryDateView.alpha = 0
                self.inputCvcView.alpha = 0
                self.spacerView.alpha = 0
            }
        case .uncollapsed:
            let panText = "••••" + pan.suffix(4)
            inputPanCardView.text = panText
            inputPanRightButtonMode = .empty
            expiryDateView.isHidden = false
            inputCvcView.isHidden = false
            spacerView.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.expiryDateView.alpha = 1
                self.inputCvcView.alpha = 1
                self.spacerView.alpha = 1
            }
        }
    }
}

// MARK: - ExpiryDateViewDelegate

extension BankCardView: ExpiryDateViewDelegate {
    func expiryDateDidChange(
        _ value: String
    ) {
        delegate?.bankCardExpiryDateDidChange(value)
    }
}

// MARK: - InputCvcViewDelegate

extension BankCardView: InputCvcViewDelegate {
    func cvcDidChange(
        _ value: String
    ) {
        delegate?.bankCardCvcDidChange(value)
    }
}

// MARK: - UITextField from BankCardView.BankCardFocus

private extension BankCardView.BankCardFocus {
    func field(on view: BankCardView) -> UITextField {
        switch self {
        case .pan:
            return view.inputPanCardView.cardPanTextField
        case .expiryDate:
            return view.expiryDateView.expiryDateTextField
        case .cvc:
            return view.inputCvcView.cvcTextField
        }
    }
}
