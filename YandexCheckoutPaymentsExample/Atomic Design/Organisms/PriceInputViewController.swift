import UIKit

protocol PriceInputViewControllerDelegate: class {
    func priceInputViewController(_ priceInputViewController: PriceInputViewController,
                                  didChangePrice price: Decimal?,
                                  valid: Bool)
}

final class PriceInputViewController: UIViewController {

    // MARK: - Formatter components
    private lazy var priceInputPresenter: InputPresenter = {
        let priceStyle = PriceInputPresenterStyle()
        let priceInputPresenter = InputPresenter(textInputStyle: priceStyle)
        priceInputPresenter.output = priceControl
        return priceInputPresenter
    }()

    var price: Decimal? {
        if let price = priceControl.text {
            let rawPrice = priceInputPresenter.style.removedFormatting(from: price)
            return Decimal(string: rawPrice,
                           locale: Locale.current)
        } else {
            return nil
        }
    }

    weak var delegate: PriceInputViewControllerDelegate?

    // MARK: - Initial values

    var initialPrice: Decimal?

    // MARK: - UI properties
    private lazy var priceControl: TextControl = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
        $0.setStyles(TextControl.Styles.default,
                     TextControl.Styles.noAutocorrection,
                     TextControl.Styles.noSpellChecking,
                     TextControl.Styles.noAutoCapitalization,
                     UIView.Styles.defaultBackground)
        $0.textView.setStyles(UIView.Styles.defaultBackground)
        $0.textView.keyboardType = .decimalPad
        $0.textView.tintColor = UIColor.black
        $0.lineMode = .whileActiveWithStateOrError
        $0.bottomHintMode = .whileActiveWithStateOrError
        $0.set(bottomHintText: " ", for: .normal)

        let localizedMinPrice = PriceInputFormatter.fullLocalizedCurrency(decimal: Constants.minPrice)
        $0.set(bottomHintText: translate(Localized.minPriceError) + " " + localizedMinPrice, for: .error)

        let localizedPlaceholder = PriceInputFormatter.fullLocalizedCurrency(decimal: Decimal(0))
        $0.placeholderLabel.attributedText = PriceInputFormatter.format(string: localizedPlaceholder)

        if let initialPriceDecimal = initialPrice {
            let localizedPrice = PriceInputFormatter.fullLocalizedCurrency(decimal: initialPriceDecimal)
            $0.attributedText = PriceInputFormatter.format(string: localizedPrice)
        }

        $0.textView.textAlignment = .left
        $0.placeholderLabel.textAlignment = .left

        return $0
    }(TextControl())

    // MARK: - Managing the View

    override func loadView() {
        view = UIView()
        view.backgroundColor = .clear

        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        view.addSubview(priceControl)
    }

    private func setupConstraints() {
        var constraints: [NSLayoutConstraint] = []
        constraints += [
            priceControl.leading.constraint(equalTo: view.leadingMargin),
            priceControl.trailing.constraint(equalTo: view.trailingMargin),
            priceControl.top.constraint(equalTo: view.topMargin),
            priceControl.bottom.constraint(equalTo: view.bottomMargin),
        ]
        NSLayoutConstraint.activate(constraints)
    }
}

// MARK: - TextControlDelegate
extension PriceInputViewController: TextControlDelegate {
    func textControl(_ textControl: TextControl,
                     shouldChangeTextIn range: NSRange,
                     replacementText text: String) -> Bool {

        priceInputPresenter.input(changeCharactersIn: range,
                                  replacementString: text,
                                  currentString: textControl.text ?? "")

        if let text = priceControl.text {
            priceControl.textView.attributedText = PriceInputFormatter.format(string: text)
        } else {
            priceControl.textView.attributedText = NSAttributedString(string: "")
        }

        delegate?.priceInputViewController(self,
                                           didChangePrice: price,
                                           valid: price ?? 0 >= Constants.minPrice)

        return false
    }

    func textControlDidBeginEditing(_ textControl: TextControl) {
        priceControl.state = .default
    }

    func textControlDidEndEditing(_ textControl: TextControl) {
        if let price = price, price >= Constants.minPrice {
            priceControl.state = .default
        } else {
            priceControl.state = .error
        }

        if let text = textControl.text {
            let onlyPrice = text.replacingOccurrences(of: PriceConstants.currencySymbol, with: "")
            let resultPrice = PriceInputFormatter.fullLocalizedCurrency(string: onlyPrice)
            priceControl.textView.attributedText = PriceInputFormatter.format(string: resultPrice)
        }
    }
}

private extension PriceInputViewController {
    enum Localized: String {
        case minPriceError = "Price.min.error"
    }
}

private extension PriceInputViewController {
    enum Constants {
        static let minPrice = Decimal(0.01)
    }
}
