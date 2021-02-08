import PassKit
import YooKassaPaymentsApi

final class SberbankStrategy {

    // MARK: - Outputs

    weak var output: TokenizationStrategyOutput?
    weak var contractStateHandler: ContractStateHandler?

    // MARK: - Init data

    let paymentOption: PaymentOption
    var savePaymentMethod: Bool

    // MARK: - Init

    init(
        paymentOption: PaymentOption,
        savePaymentMethod: Bool
    ) throws {
        guard case .sberbank = paymentOption.paymentMethodType else {
            throw TokenizationStrategyError.incorrectPaymentOptions
        }

        self.paymentOption = paymentOption
        self.savePaymentMethod = savePaymentMethod
    }

    // MARK: - Properties

    var shouldInvalidateTokenizeData = false
}

// MARK: - TokenizationStrategyInput

extension SberbankStrategy: TokenizationStrategyInput {
    func beginProcess() {
        output?.presentSberbankContract(paymentOption: paymentOption)
    }

    func sberbankModule(
        _ module: SberbankModuleInput,
        didPressConfirmButton phoneNumber: String
    ) {
        contractStateHandler = module
        let confirmation = Confirmation(type: .external, returnUrl: nil)
        let tokenizeData = TokenizeData.sberbank(
            phoneNumber: phoneNumber,
            confirmation: confirmation,
            savePaymentMethod: savePaymentMethod
        )
        module.showActivity()
        output?.tokenize(tokenizeData, paymentOption: paymentOption)
    }

    func failTokenizeData(_ error: Error) {
        contractStateHandler?.failTokenizeData(error)
    }

    func bankCardDataInputModule(
        _ module: BankCardDataInputModuleInput,
        didPressConfirmButton bankCardData: CardData
    ) {}
    func failLoginInWallet(_ error: Error) {}
    func failResendSmsCode(_ error: Error) {}
    func didPressConfirmButton(
        on module: BankCardDataInputModuleInput,
        cvc: String
    ) {}
    func didPressLogout() {}
    func paymentAuthorizationViewController(
        _ controller: PassKit.PKPaymentAuthorizationViewController,
        didAuthorizePayment payment: PassKit.PKPayment,
        completion: @escaping (PassKit.PKPaymentAuthorizationStatus) -> Void
    ) {}
    func paymentAuthorizationViewControllerDidFinish(_ controller: PassKit.PKPaymentAuthorizationViewController) {}
    func didPresentApplePayModule() {}
    func didFailPresentApplePayModule() {}
    func didPressSubmitButton(on module: ApplePayContractModuleInput) {}
    func didPressSubmitButton(on module: ContractModuleInput) {}
    func didLoginInWallet(_ response: WalletLoginResponse) {}
    func didTokenizeData() {}
}
