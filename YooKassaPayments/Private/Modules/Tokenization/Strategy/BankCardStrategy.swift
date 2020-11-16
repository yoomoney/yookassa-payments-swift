import FunctionalSwift
import PassKit
import YooKassaPaymentsApi

final class BankCardStrategy {

    weak var output: TokenizationStrategyOutput?
    weak var contractStateHandler: ContractStateHandler?

    private weak var bankCardDataInputModule: BankCardDataInputModuleInput?

    var shouldInvalidateTokenizeData = false
    var savePaymentMethod: Bool

    private let paymentOption: PaymentOption
    private let returnUrl: String

    init(
        paymentOption: PaymentOption,
        returnUrl: String,
        savePaymentMethod: Bool
    ) throws {
        guard case .bankCard = paymentOption.paymentMethodType else {
            throw TokenizationStrategyError.incorrectPaymentOptions
        }
        self.paymentOption = paymentOption
        self.returnUrl = returnUrl
        self.savePaymentMethod = savePaymentMethod
    }
}

extension BankCardStrategy: TokenizationStrategyInput {
    func beginProcess() {
        output?.presentContract(paymentOption: paymentOption)
    }

    func didPressSubmitButton(
        on module: ContractModuleInput
    ) {
        output?.presentBankCardDataInput()
    }

    func bankCardDataInputModule(
        _ module: BankCardDataInputModuleInput,
        didPressConfirmButton bankCardData: CardData
    ) {
        guard let bankCard = makeBankCard(bankCardData) else {
            // TODO: show error
            return
        }
        bankCardDataInputModule = module
        let confirmation = makeConfirmation(returnUrl: returnUrl)
        let tokenizeData: TokenizeData = .bankCard(
            bankCard: bankCard,
            confirmation: confirmation,
            savePaymentMethod: savePaymentMethod
        )
        output?.tokenize(tokenizeData, paymentOption: paymentOption)
    }

    func failTokenizeData(_ error: Error) {
        bankCardDataInputModule?.bankCardDidTokenize(error)
    }

    func sberbankModule(_ module: SberbankModuleInput, didPressConfirmButton phoneNumber: String) {}
    func didPressConfirmButton(on module: BankCardDataInputModuleInput, cvc: String) {}
    func failResendSmsCode(_ error: Error) {}
    func yamoneyAuthParameters(_ module: YamoneyAuthParametersModuleInput,
                               loginWithReusableToken isReusableToken: Bool) {}
    func didPressLogout() {}
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController,
                                            didAuthorizePayment payment: PKPayment,
                                            completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {}
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {}
    func didFailPresentApplePayModule() {}
    func didPresentApplePayModule() {}
    func didPressSubmitButton(on module: ApplePayContractModuleInput) {}
    func didLoginInWallet(_ response: YamoneyLoginResponse) {}
    func failLoginInWallet(_ error: Error) {}
    func didTokenizeData() {}
}

private func makeBankCard(_ cardData: CardData) -> BankCard? {
    guard let number = cardData.pan,
          let expiryDateComponents = cardData.expiryDate,
          let expiryYear = String.init -<< expiryDateComponents.year,
          let expiryMonth = String.init -<< expiryDateComponents.month,
          let csc = cardData.csc else {
        return nil
    }
    let bankCard = BankCard(number: number,
                            expiryYear: expiryYear,
                            expiryMonth: makeCorrectExpiryMonth(expiryMonth),
                            csc: csc,
                            cardholder: nil)
    return bankCard
}

private func makeCorrectExpiryMonth(_ month: String) -> String {
    return month.count > 1 ? month : "0" + month
}

private func makeConfirmation(returnUrl: String) -> Confirmation {
    return Confirmation(type: .redirect, returnUrl: returnUrl)
}
