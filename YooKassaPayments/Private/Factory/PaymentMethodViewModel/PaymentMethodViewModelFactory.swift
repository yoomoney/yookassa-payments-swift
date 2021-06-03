import class UIKit.UIImage
import YooKassaPaymentsApi

protocol PaymentMethodViewModelFactory {

    // MARK: - Replace bullets

    func replaceBullets(_ pan: String) -> String

    // MARK: - Transform ViewModel from PaymentOption

    func makePaymentMethodViewModel(
        paymentOption: PaymentOption,
        walletDisplayName: String?
    ) -> PaymentMethodViewModel

    func makePaymentMethodViewModel(
        paymentOption: PaymentOption
    ) -> PaymentMethodViewModel

    // MARK: - Making ViewModel from PaymentMethodType

    func makePaymentMethodViewModel(
        _ paymentMethodType: YooKassaPaymentsApi.PaymentMethodType
    ) -> PaymentMethodViewModel

    // MARK: - Make Image

    func makeBankCardImage(
        _ paymentOption: PaymentInstrumentYooMoneyLinkedBankCard
    ) -> UIImage

    func makeBankCardImage(
        _ paymentMethodBankCard: PaymentMethodBankCard
    ) -> UIImage

    func makePaymentMethodTypeImage(
        _ paymentMethodType: YooKassaPaymentsApi.PaymentMethodType
    ) -> UIImage
}
