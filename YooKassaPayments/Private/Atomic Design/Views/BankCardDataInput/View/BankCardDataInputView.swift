import UIKit

final class BankCardDataInputView: UIView {

    enum BankCardFocus {
        case pan
        case expiryDate
        case cvc
    }

    enum InputState {
        case collapsed
        case uncollapsed
    }

    // MARK: - VIPER

    var output: BankCardDataInputViewOutput!

    // MARK: - UI properties

    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setStyles(
            UIView.Styles.grayBackground
        )
        view.layoutMargins = .zero
        return view
    }()

    private lazy var inputsContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setStyles(
            UIView.Styles.grayBackground,
            UIView.Styles.roundedShadow
        )
        view.layoutMargins = UIEdgeInsets(
            top: 12,
            left: Space.double,
            bottom: 12,
            right: Space.double
        )
        return view
    }()

    private lazy var verticalStackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = Space.single
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
        view.setStyles(
            UILabel.DynamicStyle.caption1,
            UILabel.ColorStyle.alert,
            UILabel.Styles.singleLine
        )
        view.alpha = 0
        return view
    }()

    private lazy var inputPanCardView: InputPanCardView = {
        let view = InputPanCardView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()

    private lazy var inputExpiryDateView: InputExpiryDateView = {
        let view = InputExpiryDateView()
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

    // MARK: - Drawing and Updating the View

    private lazy var setupViewOnce: () = {
        output.setupView()
    }()

    override func draw(
        _ rect: CGRect
    ) {
        super.draw(rect)
        _ = setupViewOnce
    }

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
            top: Space.double,
            left: Space.double,
            bottom: 0,
            right: Space.double
        )
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        [
            containerView,
        ].forEach(addSubview)
        [
            verticalStackView,
        ].forEach(containerView.addSubview)
        [
            inputsContainerView,
            bottomHintLabel,
        ].forEach(verticalStackView.addArrangedSubview)
        [
            horizontalStackView,
        ].forEach(inputsContainerView.addSubview)
        [
            inputPanCardView,
            inputExpiryDateView,
            spacerView,
            inputCvcView,
        ].forEach(horizontalStackView.addArrangedSubview)
    }

    private func setupConstraints() {
        let constraints = [
            containerView.topAnchor.constraint(
                equalTo: layoutMarginsGuide.topAnchor
            ),
            containerView.bottomAnchor.constraint(
                equalTo: layoutMarginsGuide.bottomAnchor
            ),
            containerView.leadingAnchor.constraint(
                equalTo: layoutMarginsGuide.leadingAnchor
            ),
            containerView.trailingAnchor.constraint(
                equalTo: layoutMarginsGuide.trailingAnchor
            ),

            verticalStackView.topAnchor.constraint(
                equalTo: containerView.layoutMarginsGuide.topAnchor
            ),
            verticalStackView.bottomAnchor.constraint(
                equalTo: containerView.layoutMarginsGuide.bottomAnchor
            ),
            verticalStackView.leadingAnchor.constraint(
                equalTo: containerView.layoutMarginsGuide.leadingAnchor
            ),
            verticalStackView.trailingAnchor.constraint(
                equalTo: containerView.layoutMarginsGuide.trailingAnchor
            ),

            horizontalStackView.topAnchor.constraint(
                equalTo: inputsContainerView.layoutMarginsGuide.topAnchor
            ),
            horizontalStackView.bottomAnchor.constraint(
                equalTo: inputsContainerView.layoutMarginsGuide.bottomAnchor
            ),
            horizontalStackView.leadingAnchor.constraint(
                equalTo: inputsContainerView.layoutMarginsGuide.leadingAnchor
            ),
            horizontalStackView.trailingAnchor.constraint(
                equalTo: inputsContainerView.layoutMarginsGuide.trailingAnchor
            ),

            inputsContainerView.heightAnchor.constraint(
                equalToConstant: 70
            ),

            bottomHintLabel.heightAnchor.constraint(
                equalToConstant: Space.double
            ),

            inputPanCardView.widthAnchor.constraint(
                greaterThanOrEqualToConstant: 124
            ),
            inputExpiryDateView.widthAnchor.constraint(
                greaterThanOrEqualToConstant: 94
            ),
            inputCvcView.widthAnchor.constraint(
                greaterThanOrEqualToConstant: 36
            ),

            spacerView.widthAnchor.constraint(
                equalToConstant: Space.single
            ),
        ]
        NSLayoutConstraint.activate(constraints)
    }
}

// MARK: - BankCardDataInputViewInput

extension BankCardDataInputView: BankCardDataInputViewInput {

    func setViewModel(
        _ viewModel: BankCardDataInputViewModel
    ) {
        inputPanCardView.hint = viewModel.inputPanHint
        inputPanCardView.placeholder = viewModel.inputPanPlaceholder
        inputExpiryDateView.hint = viewModel.inputExpiryDateHint
        inputExpiryDateView.placeholder = viewModel.inputExpiryDatePlaceholder
        inputCvcView.hint = viewModel.inputCvcHint
        inputCvcView.placeholder = viewModel.inputCvcPlaceholder
    }

    var focus: BankCardFocus? {
        get {
            [BankCardFocus.pan, .expiryDate, .cvc].first {
                $0.field(on: self).isFirstResponder
            }
        }
        set {
            newValue?.field(on: self).becomeFirstResponder()
        }
    }

    func setBankLogoImage(
        _ image: UIImage?
    ) {
        inputPanCardView.logo = image
    }

    func setCardViewMode(
        _ mode: InputPanCardView.RightButtonMode
    ) {
        inputPanCardView.rightButtonMode = mode
    }

    func setPanValue(
        _ value: String
    ) {
        inputPanCardView.text = value
    }

    func setExpiryDateValue(
        _ value: String
    ) {
        inputExpiryDateView.text = value
    }

    func setInputState(
        _ state: BankCardDataInputView.InputState
    ) {
        switch state {
        case .collapsed:
            inputExpiryDateView.isHidden = true
            inputCvcView.isHidden = true
            spacerView.isHidden = true
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let self = self else { return }
                self.inputExpiryDateView.alpha = 0
                self.inputCvcView.alpha = 0
                self.spacerView.alpha = 0
            }
        case .uncollapsed:
            inputExpiryDateView.isHidden = false
            inputCvcView.isHidden = false
            spacerView.isHidden = false
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let self = self else { return }
                self.inputExpiryDateView.alpha = 1
                self.inputCvcView.alpha = 1
                self.spacerView.alpha = 1
            }
        }
    }

    func setErrorState(
        _ state: BankCardDataInputViewErrorState
    ) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            switch state {
            case .noError:
                self.inputsContainerView.setStyles(UIView.Styles.grayBorder)
                self.inputPanCardView.setStyles(InputPanCardView.Styles.default)
                self.inputExpiryDateView.setStyles(InputExpiryDateView.Styles.default)
                self.bottomHintLabel.text = ""
                self.bottomHintLabel.alpha = 0
            case .panError:
                self.inputsContainerView.setStyles(UIView.Styles.alertBorder)
                self.inputPanCardView.setStyles(InputPanCardView.Styles.error)
                self.bottomHintLabel.text = §Localized.BottomHint.invalidPan
                self.bottomHintLabel.alpha = 1
            case .expiryDateError:
                self.inputsContainerView.setStyles(UIView.Styles.alertBorder)
                self.inputExpiryDateView.setStyles(InputExpiryDateView.Styles.error)
                self.inputPanCardView.setStyles(InputPanCardView.Styles.default)
                self.bottomHintLabel.text = §Localized.BottomHint.invalidExpiry
                self.bottomHintLabel.alpha = 1
            }
        }
    }
}

// MARK: - InputPanCardViewDelegate

extension BankCardDataInputView: InputPanCardViewDelegate {
    func panDidChange(
        _ value: String
    ) {
        output.didChangePan(value)
    }

    func scanDidPress() {
        output.didPressScan()
    }

    func nextDidPress() {
        output.nextDidPress()
    }

    func panDidBeginEditing() {
        output.panDidBeginEditing()
    }

}

// MARK: - InputExpiryDateViewDelegate

extension BankCardDataInputView: InputExpiryDateViewDelegate {
    func expiryDateDidChange(
        _ value: String
    ) {
        output.didChangeExpiryDate(value)
    }

    func expiryDateDidBeginEditing() {
        output.expiryDateDidBeginEditing()
    }
}

// MARK: - InputCvcViewDelegate

extension BankCardDataInputView: InputCvcViewDelegate {
    func cvcDidChange(
        _ value: String
    ) {
        output.didChangeCvc(value)
    }
}

// MARK: - UITextField from BankCardView.BankCardFocus

private extension BankCardDataInputView.BankCardFocus {
    func field(on view: BankCardDataInputView) -> UITextField {
        switch self {
        case .pan:
            return view.inputPanCardView.cardPanTextField
        case .expiryDate:
            return view.inputExpiryDateView.expiryDateTextField
        case .cvc:
            return view.inputCvcView.cvcTextField
        }
    }
}

// MARK: - Localized

private extension BankCardDataInputView {
    enum Localized {
        enum BottomHint: String {
            case invalidPan = "BankCardDataInputView.BottomHint.invalidPan"
            case invalidExpiry = "BankCardDataInputView.BottomHint.invalidExpiry"
        }
    }
}
