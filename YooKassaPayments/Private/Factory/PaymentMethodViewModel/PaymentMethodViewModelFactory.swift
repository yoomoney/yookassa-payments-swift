import class UIKit.UIImage
import YooKassaPaymentsApi

protocol PaymentMethodViewModelFactory {

    // MARK: - Transform ViewModel from PaymentOption

    func makePaymentMethodViewModels(
        _ paymentOptions: [PaymentOption],
        walletDisplayName: String?
    ) -> (models: [PaymentMethodViewModel], indexMap: ([Int: Int]))

    func makePaymentMethodViewModel(
        paymentOption: PaymentInstrumentYooMoneyWallet,
        walletDisplayName: String?
    ) -> PaymentMethodViewModel

    // MARK: - Make Image

    func makeBankCardImage(
        _ paymentOption: PaymentInstrumentYooMoneyLinkedBankCard
    ) -> UIImage

    func makeBankCardImage(
        first6Digits: String?,
        bankCardType: BankCardType
    ) -> UIImage

    // MARK: - Replace bullets

    func replaceBullets(_ pan: String) -> String

    func makeMaskedPan(_ cardMask: String) -> String

    func yooLogoImage() -> UIImage
}
