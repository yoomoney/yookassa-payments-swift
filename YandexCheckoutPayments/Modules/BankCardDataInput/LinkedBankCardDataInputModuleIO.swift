import class YandexCheckoutPaymentsApi.PaymentInstrumentYandexMoneyLinkedBankCard
import class YandexCheckoutPaymentsApi.PaymentOption

struct LinkedBankCardDataInputModuleInputData {
    let paymentOption: PaymentInstrumentYandexMoneyLinkedBankCard
    let testModeSettings: TestModeSettings?
}

protocol LinkedBankCardDataInputModuleOutput: class {
    func didPressCloseBarButtonItem(on module: BankCardDataInputModuleInput)
    func didPressConfirmButton(on module: BankCardDataInputModuleInput,
                               cvc: String)
}
