import class UIKit.UIImage
import YooKassaPaymentsApi

enum PaymentMethodViewModelFactory {

    // MARK: - Transform model to ViewModel

    static func makePaymentMethodViewModel(
        paymentOption: PaymentOption,
        walletDisplayName: String?
    ) -> PaymentMethodViewModel {
        let viewModel: PaymentMethodViewModel
        switch paymentOption {
        case let paymentOption as PaymentInstrumentYooMoneyWallet:
            viewModel = makePaymentMethodViewModel(paymentOption, walletDisplayName: walletDisplayName)
        case let paymentOption as PaymentInstrumentYooMoneyLinkedBankCard:
            viewModel = makePaymentMethodViewModel(paymentOption)
        default:
            viewModel = makePaymentMethodViewModel(paymentOption.paymentMethodType)
        }
        return viewModel
    }

    // MARK: - Making masked card pan

    static func makeMaskedPan(_ pan: String) -> String {
        let replacedPan = replaceBullets(pan)
        return replacedPan.chunks(of: 4).joined(separator: " ")
    }

    static func replaceBullets(_ pan: String) -> String {
        return pan.replacingOccurrences(of: "*", with: "•")
    }

    // MARK: - Making ViewModel from PaymentInstrumentYooMoneyWallet

    private static func makePaymentMethodViewModel(
        _ paymentOption: PaymentInstrumentYooMoneyWallet,
        walletDisplayName: String?
    ) -> PaymentMethodViewModel {
        return PaymentMethodViewModel(
            name: walletDisplayName ?? paymentOption.accountId,
            image: PaymentMethodResources.Image.yooMoney,
            balance: MonetaryAmountFactory.makeAmount(paymentOption.balance)
        )
    }

    // MARK: - Making ViewModel from PaymentInstrumentYooMoneyLinkedBankCard

    private static func makePaymentMethodViewModel(
        _ paymentOption: PaymentInstrumentYooMoneyLinkedBankCard
    ) -> PaymentMethodViewModel {
        return PaymentMethodViewModel(
            name: makePaymentMethodViewModelName(paymentOption),
            image: makePaymentMethodViewModelImage(paymentOption),
            balance: nil
        )
    }

    private static func makePaymentMethodViewModelName(
        _ paymentOption: PaymentInstrumentYooMoneyLinkedBankCard
    ) -> String {
        return paymentOption.cardName
            ?? makeMaskedPan(paymentOption.cardMask)
    }

    // swiftlint:disable cyclomatic_complexity
    private static func makePaymentMethodViewModelImage(
        _ paymentOption: PaymentInstrumentYooMoneyLinkedBankCard
    ) -> UIImage {
        let image: UIImage
        switch paymentOption.cardType {
        case .masterCard:      image = PaymentMethodResources.Image.mastercard
        case .visa:            image = PaymentMethodResources.Image.visa
        case .mir:             image = PaymentMethodResources.Image.mir
        case .americanExpress: image = PaymentMethodResources.Image.americanExpress
        case .jcb:             image = PaymentMethodResources.Image.jcb
        case .cup:             image = PaymentMethodResources.Image.cup
        case .dinersClub:      image = PaymentMethodResources.Image.dinersClub
        case .bankCard:        image = PaymentMethodResources.Image.bankCard
        case .discoverCard:    image = PaymentMethodResources.Image.discoverCard
        case .instaPayment:    image = PaymentMethodResources.Image.instapay
        case .laser:           image = PaymentMethodResources.Image.lazer
        case .dankort:         image = PaymentMethodResources.Image.dankort
        case .solo:            image = PaymentMethodResources.Image.solo
        case .switch:          image = PaymentMethodResources.Image.switch
        case .unknown:         image = PaymentMethodResources.Image.unknown
        }
        return image
    }
    // swiftlint:enable cyclomatic_complexity

    // MARK: - Making ViewModel from PaymentMethodType

    static func makePaymentMethodViewModel(
        _ paymentMethodType: YooKassaPaymentsApi.PaymentMethodType
    ) -> PaymentMethodViewModel {
        return PaymentMethodViewModel(
            name: makePaymentMethodViewModelName(paymentMethodType),
            image: makePaymentMethodViewModelImage(paymentMethodType),
            balance: nil
        )
    }

    private static func makePaymentMethodViewModelName(
        _ paymentMethodType: YooKassaPaymentsApi.PaymentMethodType
    ) -> String {
        let name: String
        switch paymentMethodType {
        case .bankCard:
            name = §PaymentMethodResources.Localized.bankCard
        case .yooMoney:
            name = §PaymentMethodResources.Localized.wallet
        case .applePay:
            name = §PaymentMethodResources.Localized.applePay
        case .sberbank:
            name = §PaymentMethodResources.Localized.sberbank
        default:
            assertionFailure("Unsupported PaymentMethodType")
            name = "Unsupported"
        }
        return name
    }

    private static func makePaymentMethodViewModelImage(
        _ paymentMethodType: YooKassaPaymentsApi.PaymentMethodType
    ) -> UIImage {
        let image: UIImage
        switch paymentMethodType {
        case .bankCard:
            image = PaymentMethodResources.Image.unknown
        case .yooMoney:
            image = PaymentMethodResources.Image.yooMoney
        case .applePay:
            image = PaymentMethodResources.Image.applePay
        case .sberbank:
            image = PaymentMethodResources.Image.sberbank
        default:
            assertionFailure("Unsupported PaymentMethodType")
            image = UIImage()
        }
        return image
    }
}
