import YooKassaPaymentsApi

final class BankCardRepeatPresenter {

    // MARK: - VIPER

    var router: TokenizationRouterInput!
    var interactor: BankCardRepeatInteractorInput!

    weak var moduleOutput: TokenizationModuleOutput?
    weak var view: TokenizationViewInput?

    weak var contractModuleInput: ContractModuleInput?
    weak var bankCardDataInputModuleInput: BankCardDataInputModuleInput?

    // MARK: - Stored Data

    private var savePaymentMethod = true

    // MARK: - Init data

    private let inputData: BankCardRepeatModuleInputData

    // MARK: - Init

    init(inputData: BankCardRepeatModuleInputData) {
        self.inputData = inputData
    }
}

// MARK: - TokenizationViewOutput

extension BankCardRepeatPresenter: TokenizationViewOutput {
    func setupView() {
        view?.setCustomizationSettings(inputData.customizationSettings)
        presentContract()
    }

    func closeDidPress() {
        moduleOutput?.didFinish(on: self, with: nil)
    }

    private func presentContract() {

        let viewModel = PaymentMethodViewModelFactory.makePaymentMethodViewModel(.bankCard)
        let tokenizeScheme = AnalyticsEvent.TokenizeScheme.recurringCard
        let savePaymentMethodViewModel = SavePaymentMethodViewModelFactory.makeSavePaymentMethodViewModel(
            inputData.savePaymentMethod,
            initialState: makeInitialSavePaymentMethod(inputData.savePaymentMethod)
        )
        let moduleInputData = ContractModuleInputData(
            shopName: inputData.shopName,
            purchaseDescription: inputData.purchaseDescription,
            paymentMethod: viewModel,
            price: makePriceViewModel(inputData.amount),
            fee: nil,
            shouldChangePaymentMethod: false,
            testModeSettings: inputData.testModeSettings,
            tokenizeScheme: tokenizeScheme,
            isLoggingEnabled: inputData.isLoggingEnabled,
            termsOfService: TermsOfServiceFactory.makeTermsOfService(),
            savePaymentMethodViewModel: savePaymentMethodViewModel
        )

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.router.presentContract(inputData: moduleInputData,
                                        moduleOutput: self)
        }
    }
}

// MARK: - BankCardRepeatInteractorOutput

extension BankCardRepeatPresenter: BankCardRepeatInteractorOutput {
    func didFetchPaymentMethod(
        _ paymentMethod: YooKassaPaymentsApi.PaymentMethod) {
        guard let card = paymentMethod.card,
              card.first6.isEmpty == false,
              card.last4.isEmpty == false else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.moduleOutput?.didFinish(on: self, with: .paymentMethodNotFound)
            }
            return
        }
        let cardMask = card.first6 + "******" + card.last4
        let moduleInputData = MaskedBankCardDataInputModuleInputData(
            cardMask: cardMask,
            testModeSettings: inputData.testModeSettings,
            isLoggingEnabled: inputData.isLoggingEnabled,
            analyticsEvent: .screenRecurringCardForm,
            tokenizeScheme: .recurringCard
        )

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.router.presenMaskedBankCardDataInput(
                inputData: moduleInputData,
                moduleOutput: self
            )
        }
    }

    func didFailFetchPaymentMethod(_ error: Error) {
        if let error = error as? PaymentsApiError {
            switch error.errorCode {
            case .invalidRequest, .notSupported:
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.moduleOutput?.didFinish(on: self, with: .paymentMethodNotFound)
                }
            default:
                showError(error)
            }
        } else {
            showError(error)
        }
    }

    func didTokenize(_ tokens: Tokens) {
        moduleOutput?.tokenizationModule(
            self,
            didTokenize: tokens,
            paymentMethodType: .bankCard
        )
    }

    func didFailTokenize(_ error: Error) {
        bankCardDataInputModuleInput?.bankCardDidTokenize(error)
    }

    private func showError(_ error: Error) {
        let authType = AnalyticsEvent.AuthType.withoutAuth
        let scheme = AnalyticsEvent.TokenizeScheme.recurringCard
        let event = AnalyticsEvent.screenError(authType: authType, scheme: scheme)
        interactor.trackEvent(event)

        let message = makeMessage(error)
        contractModuleInput?.hideActivity()
        contractModuleInput?.showPlaceholder(message: message)
    }
}

// MARK: - ContractModuleOutput

extension BankCardRepeatPresenter: ContractModuleOutput {
    func didPressSubmitButton(on module: ContractModuleInput) {
        contractModuleInput = module

        module.hidePlaceholder()
        module.showActivity()

        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            self.interactor.fetchPaymentMethod(
                paymentMethodId: self.inputData.paymentMethodId
            )
        }
    }

    func didPressChangeAction(on module: ContractModuleInput) {}

    func didPressLogoutButton(on module: ContractModuleInput) {}

    func didFinish(on module: ContractModuleInput) {
        moduleOutput?.didFinish(on: self, with: nil)
    }

    func contractModule(_ module: ContractModuleInput, didTapTermsOfService url: URL) {
        router.presentTermsOfServiceModule(url)
    }

    func contractModule(_ module: ContractModuleInput, didChangeSavePaymentMethodState state: Bool) {
        savePaymentMethod = state
    }

    func didTapOnSavePaymentMethodInfo(on module: ContractModuleInput) {
        let savePaymentMethodModuleinputData = SavePaymentMethodInfoModuleInputData(
            customizationSettings: inputData.customizationSettings,
            headerValue: §SavePaymentMethodInfoLocalization.BankCard.header,
            bodyValue: §SavePaymentMethodInfoLocalization.BankCard.body
        )
        router.presentSavePaymentMethodInfo(inputData: savePaymentMethodModuleinputData)
    }
}

// MARK: - MaskedBankCardDataInputModuleOutput

extension BankCardRepeatPresenter: MaskedBankCardDataInputModuleOutput {
    func didPressCloseBarButtonItem(on module: BankCardDataInputModuleInput) {
        moduleOutput?.didFinish(on: self, with: nil)
    }

    func didPressConfirmButton(on module: BankCardDataInputModuleInput, cvc: String) {
        bankCardDataInputModuleInput = module

        let confirmation = Confirmation(
            type: .redirect,
            returnUrl: "https://custom.redirect.url/"
        )

        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            self.interactor.tokenize(
                amount: MonetaryAmountFactory.makePaymentsMonetaryAmount(self.inputData.amount),
                confirmation: confirmation,
                savePaymentMethod: self.savePaymentMethod,
                paymentMethodId: self.inputData.paymentMethodId,
                csc: cvc
            )
        }
    }
}

// MARK: - TokenizationModuleInput

extension BankCardRepeatPresenter: TokenizationModuleInput {
    func start3dsProcess(requestUrl: String, redirectUrl: String) {
        let moduleInputData = CardSecModuleInputData(
            requestUrl: requestUrl,
            redirectUrl: inputData.returnUrl ?? Constants.returnUrl,
            isLoggingEnabled: inputData.isLoggingEnabled
        )
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.router.present3dsModule(
                inputData: moduleInputData,
                moduleOutput: strongSelf
            )
        }
    }

    func start3dsProcess(requestUrl: String) {
        let moduleInputData = CardSecModuleInputData(
            requestUrl: requestUrl,
            redirectUrl: inputData.returnUrl ?? Constants.returnUrl,
            isLoggingEnabled: inputData.isLoggingEnabled
        )
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.router.present3dsModule(
                inputData: moduleInputData,
                moduleOutput: strongSelf
            )
        }
    }
}

// MARK: - CardSecModuleOutput

extension BankCardRepeatPresenter: CardSecModuleOutput {
    func didSuccessfullyPassedCardSec(on module: CardSecModuleInput) {
        moduleOutput?.didSuccessfullyPassedCardSec(on: self)
    }

    func didPressCloseButton(on module: CardSecModuleInput) {
        moduleOutput?.didFinish(on: self, with: nil)
    }
}

// MARK: - Constants

private enum Constants {
    static let returnUrl = "https://custom.redirect.url/"
}

// MARK: - Private global helpers

private func makePriceViewModel(_ amount: Amount) -> PriceViewModel {
    let amountString = amount.value.description
    var integerPart = ""
    var fractionalPart = ""

    if let separatorIndex = amountString.firstIndex(of: ".") {
        integerPart = String(amountString[amountString.startIndex..<separatorIndex])
        fractionalPart = String(amountString[amountString.index(after: separatorIndex)..<amountString.endIndex])
    } else {
        integerPart = amountString
        fractionalPart = "00"
    }
    return TempAmount(currency: amount.currency.symbol,
                      integerPart: integerPart,
                      fractionalPart: fractionalPart,
                      style: .amount)
}

private func makeInitialSavePaymentMethod(
    _ savePaymentMethod: SavePaymentMethod
) -> Bool {
    let initialSavePaymentMethod: Bool
    switch savePaymentMethod {
    case .on:
        initialSavePaymentMethod = true
    case .off, .userSelects:
        initialSavePaymentMethod = false
    }
    return initialSavePaymentMethod
}

private func makeMessage(_ error: Error) -> String {
    let message: String

    switch error {
    case let error as PresentableError:
        message = error.message
    default:
        message = §CommonLocalized.Error.unknown
    }

    return message
}
