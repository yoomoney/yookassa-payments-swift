import PassKit
import YooKassaPaymentsApi

enum TokenizationStrategyError: Error {
    case incorrectPaymentOptions
}

protocol TokenizationStrategyInput: class {

    var output: TokenizationStrategyOutput? { get set }
    var contractStateHandler: ContractStateHandler? { get set }
    var savePaymentMethod: Bool { get set }
    var shouldInvalidateTokenizeData: Bool { get set }

    func beginProcess()
    func didTokenizeData()

    func didPressSubmitButton(
        on module: ContractModuleInput
    )
    func didLoginInWallet(
        _ response: WalletLoginResponse
    )

    func failTokenizeData(
        _ error: Error
    )
    func failLoginInWallet(
        _ error: Error
    )
    func failResendSmsCode(
        _ error: Error
    )

    // MARK: - Sberbank

    func sberbankModule(
        _ module: SberbankModuleInput,
        didPressConfirmButton phoneNumber: String
    )

    // MARK: - Bank card inputs

    func bankCardDataInputModule(
        _ module: BankCardDataInputModuleInput,
        didPressConfirmButton bankCardData: CardData
    )

    func didPressConfirmButton(
        on module: BankCardDataInputModuleInput,
        cvc: String
    )

    func didPressLogout()

    // MARK: - ApplePayContract

    func didPressSubmitButton(
        on module: ApplePayContractModuleInput
    )
}

protocol TokenizationStrategyOutput: class {

    func presentPaymentMethodsModule()

    func presentContract(
        paymentOption: PaymentOption
    )

    func presentBankCardDataInput()

    func presentMaskedBankCardDataInput(
        paymentOption: PaymentInstrumentYooMoneyLinkedBankCard
    )

    func presentSberbankContract(
        paymentOption: PaymentOption
    )

    func tokenize(
        _ data: TokenizeData,
        paymentOption: PaymentOption
    )

    func loginInWallet(
        reusableToken: Bool,
        paymentOption: PaymentOption
    )

    func logout(
        accountId: String
    )

    func presentErrorWithMessage(
        _ message: String
    )

    func didFinish(
        on module: TokenizationStrategyInput
    )
}
