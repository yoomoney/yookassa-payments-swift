final class BankCardDataInputPresenter {

    // MARK: - VIPER

    weak var view: BankCardDataInputViewInput?
    weak var moduleOutput: BankCardDataInputModuleOutput?
    var interactor: BankCardDataInputInteractorInput!
    var router: BankCardDataInputRouterInput!

    // MARK: - Initialization

    private let inputPanHint: String
    private let inputPanPlaceholder: String
    private let inputExpiryDateHint: String
    private let inputExpiryDatePlaceholder: String
    private let inputCvcHint: String
    private let inputCvcPlaceholder: String
    private let cardScanner: CardScanning?
    private let bankCardImageFactory: BankCardImageFactory

    init(
        inputPanHint: String,
        inputPanPlaceholder: String,
        inputExpiryDateHint: String,
        inputExpiryDatePlaceholder: String,
        inputCvcHint: String,
        inputCvcPlaceholder: String,
        cardScanner: CardScanning?,
        bankCardImageFactory: BankCardImageFactory
    ) {
        self.inputPanHint = inputPanHint
        self.inputPanPlaceholder = inputPanPlaceholder
        self.inputExpiryDateHint = inputExpiryDateHint
        self.inputExpiryDatePlaceholder = inputExpiryDatePlaceholder
        self.inputCvcHint = inputCvcHint
        self.inputCvcPlaceholder = inputCvcPlaceholder
        self.cardScanner = cardScanner
        self.bankCardImageFactory = bankCardImageFactory
    }

    // MARK: - Stored data

    private var cardData = CardData(
        pan: nil,
        expiryDate: nil,
        csc: nil
    )
    private var expiryDateText = ""
}

// MARK: - BankCardDataInputViewOutput

extension BankCardDataInputPresenter: BankCardDataInputViewOutput {
    func setupView() {
        guard let view = view else { return }
        let viewModel = BankCardDataInputViewModel(
            inputPanHint: inputPanHint,
            inputPanPlaceholder: inputPanPlaceholder,
            inputExpiryDateHint: inputExpiryDateHint,
            inputExpiryDatePlaceholder: inputExpiryDatePlaceholder,
            inputCvcHint: inputCvcHint,
            inputCvcPlaceholder: inputCvcPlaceholder
        )
        view.setViewModel(viewModel)

        cardScanner != nil
            ? view.setCardViewMode(.scan)
            : view.setCardViewMode(.empty)
    }

    func didChangePan(
        _ value: String
    ) {
        cardData.pan = value
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            self.interactor.validate(
                cardData: self.cardData,
                shouldMoveFocus: true
            )
            self.interactor.fetchBankCardSettings(value)
        }
    }

    func didChangeExpiryDate(
        _ value: String
    ) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            defer {
                self.interactor.validate(
                    cardData: self.cardData,
                    shouldMoveFocus: true
                )
            }
            self.expiryDateText = value
            guard value.count == 4 else {
                self.cardData.expiryDate = nil
                return
            }

            guard let components = makeExpiryDate(value) else {
                self.cardData.expiryDate = nil
                return
            }

            self.cardData.expiryDate = components
        }

    }

    func didChangeCvc(
        _ value: String
    ) {
        self.cardData.csc = value
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            self.interactor.validate(
                cardData: self.cardData,
                shouldMoveFocus: true
            )
        }

    }

    func didPressScan() {
        router?.openCardScanner()
        trackScanBankCardAction()
    }

    func panDidBeginEditing() {
        guard let panValue = cardData.pan,
              let view = view else { return }
        view.setPanValue(panValue)
        view.setInputState(.collapsed)
        trackCardNumberReturnToEdit()

        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            self.interactor.validate(
                cardData: self.cardData,
                shouldMoveFocus: false
            )
        }
    }

    func expiryDateDidBeginEditing() {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            self.interactor.validate(
                cardData: self.cardData,
                shouldMoveFocus: false
            )
        }
    }
    
    func expiryDateDidEndEditing() {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            self.interactor.validate(
                cardData: self.cardData,
                shouldMoveFocus: false
            )
        }
    }
    
    func cvcDidEndEditing() {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            self.interactor.validate(
                cardData: self.cardData,
                shouldMoveFocus: false
            )
        }
    }

    func nextDidPress() {
        setViewFocus(.expiryDate)
        trackCardNumberContinueAction()
    }

    func clearDidPress() {
        trackCardNumberClearAction()
    }
}

// MARK: - BankCardDataInputInteractorOutput

extension BankCardDataInputPresenter: BankCardDataInputInteractorOutput {
    func didSuccessValidateCardData(
        _ cardData: CardData
    ) {
        moduleOutput?.bankCardDataInputModule(
            self,
            didSuccessValidateCardData: cardData
        )
        DispatchQueue.main.async { [weak self] in
            guard let view = self?.view else { return }

            view.setErrorState(.noError)
            if view.focus == .pan {
                view.setCardViewMode(.next)
            }
        }
    }

    func didFailValidateCardData(
        errors: [CardService.ValidationError],
        shouldMoveFocus: Bool
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let view = self.view else { return }
            self.validatePan(errors)

            let panIsValid = errors.contains(.panInvalidLength) == false
                && errors.contains(.luhnAlgorithmFail) == false

            let dateIsValid = errors.contains(.invalidMonth) == false
                && errors.contains(.expirationDateIsExpired) == false

            self.moduleOutput?.bankCardDataInputModule(
                self,
                didFailValidateCardData: errors
            )

            if shouldMoveFocus {
                self.moveFocusIfNeeded(
                    in: view,
                    panIsValid: panIsValid,
                    dateIsValid: dateIsValid
                )
            }
        }
    }

    func didFetchBankSettings(
        _ bankSettings: BankSettings
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let view = self?.view else { return }
            let image = UIImage.named(bankSettings.logoName)
                .scaled(to: Constants.scaledImageSize)
            view.setBankLogoImage(image)
        }
    }

    func didFailFetchBankSettings(
        _ cardMask: String
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  let view = self.view else { return }
            let image = self.bankCardImageFactory.makeImage(cardMask)
            view.setBankLogoImage(image)
        }
    }
}

// MARK: - BankCardDataInputRouterOutput

extension BankCardDataInputPresenter: BankCardDataInputRouterOutput {
    func cardScanningDidFinish(_ scannedCardInfo: ScannedCardInfo) {
        scannedCardInfo.number.map(setPanAndMoveFocusNext)
        scannedCardInfo.expiryDate.map(setExpiryDateAndMoveFocusNext)

        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            self.interactor.validate(
                cardData: self.cardData,
                shouldMoveFocus: false
            )
            self.cardData.pan.map(self.interactor.fetchBankCardSettings)
        }
    }

    private func setPanAndMoveFocusNext(_ value: String) {
        guard let view = view else { return }
        cardData.pan = value
        setViewFocus(.expiryDate)
    }

    private func setExpiryDateAndMoveFocusNext(_ value: String) {
        guard let view = view,
              let expiryDate = makeExpiryDate(value) else {
            return
        }

        cardData.expiryDate = expiryDate
        view.setExpiryDateValue(value)
        setViewFocus(.cvc)
    }
}

// MARK: - BankCardDataInputModuleInput

extension BankCardDataInputPresenter: BankCardDataInputModuleInput {}

// MARK: - Private helpers

private extension BankCardDataInputPresenter {
    func validatePan(
        _ errors: [CardService.ValidationError]
    ) {
        guard let view = view else { return }
        if !errors.contains(.luhnAlgorithmFail),
           !errors.contains(.panInvalidLength),
           !errors.contains(.panEmpty),
           view.focus == .pan {
            view.setCardViewMode(.next)
        } else if errors.contains(.panEmpty) {
            cardScanner != nil
                ? view.setCardViewMode(.scan)
                : view.setCardViewMode(.empty)
        } else if errors.contains(.luhnAlgorithmFail)
                      || errors.contains(.panInvalidLength) {
            view.setCardViewMode(.clear)
        }

        if cardData.pan?.count == Constants.MoveFocusLength.pan,
           errors.contains(.luhnAlgorithmFail),
           view.focus == .pan {
            view.setErrorState(.panError)
            trackCardNumberInputError()
        } else if (view.focus == nil ||
                    view.focus == .expiryDate
                    && expiryDateText.count == Constants.MoveFocusLength.expiryDate),
                  errors.contains(.expirationDateIsExpired)
                      || errors.contains(.expiryDateEmpty)
                      || errors.contains(.invalidMonth) {
            view.setErrorState(.expiryDateError)
            trackCardExpiryInputError()
        } else if errors.contains(.cscInvalidLength),
                  view.focus == nil {
            view.setErrorState(.invalidCvc)
            trackCardCvcInputError()
        } else {
            view.setErrorState(.noError)
        }
    }

    func moveFocusIfNeeded(
        in view: BankCardDataInputViewInput,
        panIsValid: Bool,
        dateIsValid: Bool
    ) {
        switch view.focus {
        case .pan where panIsValid:
            guard let pan = cardData.pan,
                  pan.count >= Constants.MoveFocusLength.pan else {
                break
            }
            setViewFocus(.expiryDate)
            trackCardNumberInputSuccess()

        case .expiryDate where dateIsValid:
            guard expiryDateText.count == Constants.MoveFocusLength.expiryDate else {
                break
            }
            setViewFocus(.cvc)

        default:
            break
        }
    }

    func setViewFocus(
        _ focus: BankCardDataInputView.BankCardFocus?
    ) {
        guard let view = view,
              let panValue = cardData.pan else { return }
        switch focus {
        case .pan?:
            view.setInputState(.collapsed)
        case .expiryDate?, .cvc?:
            view.setInputState(.uncollapsed)
            view.setCardViewMode(.empty)
            let modifiedPanValue: String
            if UIScreen.main.isNarrow {
                modifiedPanValue = String(panValue.suffix(4))
            } else {
                modifiedPanValue = "••••" + panValue.suffix(4)
            }
            view.setPanValue(modifiedPanValue)
        default:
            break
        }
        view.focus = focus
    }
}

// MARK: - Metrics tracking

private extension BankCardDataInputPresenter {

    func trackScanBankCardAction() {
        let event: AnalyticsEvent = .actionBankCardForm(
            action: .scanBankCardAction,
            sdkVersion: Bundle.frameworkVersion
        )
        trackEvent(event)
    }

    func trackCardNumberInputError() {
        let event: AnalyticsEvent = .actionBankCardForm(
            action: .cardNumberInputError,
            sdkVersion: Bundle.frameworkVersion
        )
        trackEvent(event)
    }

    func trackCardExpiryInputError() {
        let event: AnalyticsEvent = .actionBankCardForm(
            action: .cardExpiryInputError,
            sdkVersion: Bundle.frameworkVersion
        )
        trackEvent(event)
    }
    
    func trackCardCvcInputError() {
        let event: AnalyticsEvent = .actionBankCardForm(
            action: .cardCvcInputError,
            sdkVersion: Bundle.frameworkVersion
        )
        trackEvent(event)
    }

    func trackCardNumberClearAction() {
        let event: AnalyticsEvent = .actionBankCardForm(
            action: .cardNumberClearAction,
            sdkVersion: Bundle.frameworkVersion
        )
        trackEvent(event)
    }

    func trackCardNumberInputSuccess() {
        let event: AnalyticsEvent = .actionBankCardForm(
            action: .cardNumberInputSuccess,
            sdkVersion: Bundle.frameworkVersion
        )
        trackEvent(event)
    }

    func trackCardNumberContinueAction() {
        let event: AnalyticsEvent = .actionBankCardForm(
            action: .cardNumberContinueAction,
            sdkVersion: Bundle.frameworkVersion
        )
        trackEvent(event)
    }

    func trackCardNumberReturnToEdit() {
        let event: AnalyticsEvent = .actionBankCardForm(
            action: .cardNumberReturnToEdit,
            sdkVersion: Bundle.frameworkVersion
        )
        trackEvent(event)
    }

    func trackEvent(_ event: AnalyticsEvent) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            self.interactor.trackEvent(event)
        }
    }
}

// MARK: - Constants

private extension BankCardDataInputPresenter {
    enum Constants {
        static let scaledImageSize = CGSize(width: 30, height: 30)

        enum MoveFocusLength {
            static let pan = 16
            static let expiryDate = 4
        }
    }
}

// MARK: - Private global helpers

private func makeExpiryDate(
    _ expiryDate: String
) -> DateComponents? {
    let separatedIndex = expiryDate.index(expiryDate.startIndex, offsetBy: 2)
    let monthString = expiryDate[..<separatedIndex]
    let yearString = expiryDate[separatedIndex...]

    guard let month = Int(monthString),
          let year = Int(["20", yearString].joined()) else {
        return nil
    }

    return DateComponents(
        calendar: Calendar(identifier: .gregorian),
        year: year,
        month: month
    )
}
