import UIKit

/// NumberKeyboardView delegate
@available(iOS 9.0, *)
protocol NumberKeyboardViewDelegate: class {

    /// Called on keyboard button pressed
    ///
    /// - parameter numberKeyboardView: keyboard view
    /// - parameter button:             keyboard button
    func numberKeyboardView(_ numberKeyboardView: NumberKeyboardView, didPress button: KeyboardButton)

}

/// Implementation number keyboard view, containts numbers from 0 to 9
@available(iOS 9.0, *)
class NumberKeyboardView: UIView {

    /// Keyboard view delegate
    weak var delegate: NumberKeyboardViewDelegate?

    /// Keyboard style
    var keyboardStyle: KeyboardViewStyle {
        didSet {
            setupKeyboardStyle()
        }
    }

    /// Keyboard left function button
    var leftFunctionButton: KeyboardButton? {
        get {
            guard let stackView = rowsStackView.lastRowStackView() else { return nil }
            return stackView.leftFunctionButton()
        }
        set {
            guard let stackView = rowsStackView.lastRowStackView() else { return }
            replace(functionButton: leftFunctionButton, withButton: newValue, inStackView: stackView, insertIndex: 0)
        }
    }

    /// Keyboard right function button
    var rightFunctionButton: KeyboardButton? {
        get {
            guard let stackView = rowsStackView.lastRowStackView() else { return nil }
            return stackView.rightFunctionButton()
        }
        set {
            guard let stackView = rowsStackView.lastRowStackView() else { return }
            replace(functionButton: rightFunctionButton, withButton: newValue, inStackView: stackView)
        }
    }

    required init(keyboardStyle style: KeyboardViewStyle) {
        keyboardStyle = style
        super.init(frame: .zero)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        keyboardStyle = KeyboardViewStyle()
        super.init(coder: aDecoder)
        setup()
    }

    // MARK: - Private variables
    fileprivate lazy var numberButtons: [KeyboardButton] = []

    fileprivate var placeHolderFunctionButton: KeyboardButton {
        return KeyboardButton()
    }

    fileprivate let rowsStackView: UIStackView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .vertical
        $0.distribution = .fillProportionally
        return $0
    }(UIStackView())
}

// MARK: - Actions
@available(iOS 9.0, *)
private extension NumberKeyboardView {
    @objc func buttonDidPress(_ button: KeyboardButton) {
        delegate?.numberKeyboardView(self, didPress: button)
    }
}

// MARK: - Private methods
@available(iOS 9.0, *)
private extension NumberKeyboardView {

    func setup() {
        addSubview(rowsStackView)

        setupNumberButtons()

        for index in 1...9 where (index + 1) % 3 == 0 {
            let indexWithOffset = numberButtons.index(after: index)
            let row = [KeyboardButton](numberButtons[indexWithOffset - 2...indexWithOffset])
            let stackView = rowStackView(arrangedSubviews: row)
            rowsStackView.addArrangedSubview(stackView)
        }

        let bottomRow = [placeHolderFunctionButton, numberButtons[0], placeHolderFunctionButton]
        let stackView = rowStackView(arrangedSubviews: bottomRow)
        rowsStackView.addArrangedSubview(stackView)
        setupKeyboardStyle()
        setupConstraints()
    }

    func setupConstraints() {
        var constraints: [NSLayoutConstraint] = []
        let views = ["rowsStackView": rowsStackView]
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[rowsStackView]|",
                                                      options: [],
                                                      metrics: nil,
                                                      views: views)

        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[rowsStackView]|",
                                                      options: [],
                                                      metrics: nil,
                                                      views: views)
        addConstraints(constraints)
    }

    func setupNumberButtons() {
        for number in 0...9 {
            let button = KeyboardButton()
            button.setTitle(String(number), for: .normal)
            button.identifier = String(number)
            button.addTarget(self, action: #selector(buttonDidPress(_:)), for: .touchUpInside)
            numberButtons.append(button)
        }
    }

    func setupKeyboardStyle() {
        backgroundColor = keyboardStyle.separatorLineColor
        rowsStackView.spacing = keyboardStyle.separatorLineWidth

        for view in rowsStackView.arrangedSubviews {
            guard let stackView = view as? UIStackView else { continue }
            stackView.spacing = keyboardStyle.separatorLineWidth
            stackView.backgroundColor = keyboardStyle.separatorLineColor
        }

        for button in numberButtons {
            button.style = keyboardStyle.numberButtonStyle
        }
    }

    func rowStackView(arrangedSubviews: [UIView]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }

    func replace(functionButton buttonToRemove: KeyboardButton?,
                 withButton buttonToAdd: KeyboardButton?,
                 inStackView stackView: UIStackView,
                 insertIndex: Int? = nil) {
        buttonToRemove?.removeFromSuperview()

        let newButton = buttonToAdd ?? placeHolderFunctionButton
        if let index = insertIndex {
            stackView.insertArrangedSubview(newButton, at: index)
        } else {
            stackView.addArrangedSubview(newButton)
        }
        newButton.addTarget(self, action: #selector(buttonDidPress(_:)), for: .touchUpInside)
    }
}

@available(iOS 9.0, *)
private extension UIStackView {
    func lastRowStackView() -> UIStackView? {
        return arrangedSubviews.last as? UIStackView
    }

    func leftFunctionButton() -> KeyboardButton? {
        return arrangedSubviews.first as? KeyboardButton
    }

    func rightFunctionButton() -> KeyboardButton? {
        return arrangedSubviews.last as? KeyboardButton
    }
}
