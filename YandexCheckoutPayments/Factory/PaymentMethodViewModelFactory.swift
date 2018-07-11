import FunctionalSwift
import YandexCheckoutPaymentsApi
import class UIKit.UIImage

enum PaymentMethodViewModelFactory {

    // MARK: - Transform model to ViewModel

    static func makePaymentMethodViewModel(paymentOption: PaymentOption,
                                           yandexDisplayName: String?) -> PaymentMethodViewModel {

        let viewModel: PaymentMethodViewModel
        switch paymentOption {
        case let paymentOption as PaymentInstrumentYandexMoneyWallet:
            viewModel = makePaymentMethodViewModel(paymentOption, yandexDisplayName: yandexDisplayName)
        case let paymentOption as PaymentInstrumentYandexMoneyLinkedBankCard:
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

    // MARK: - Making ViewModel from PaymentInstrumentYandexMoneyWallet

    private static func makePaymentMethodViewModel(_ paymentOption: PaymentInstrumentYandexMoneyWallet,
                                                   yandexDisplayName: String?) -> PaymentMethodViewModel {
        return PaymentMethod(name: yandexDisplayName ?? paymentOption.accountId,
                             image: PaymentMethodResources.Image.yandexWallet,
                             balance: paymentOption.balance)
    }

    // MARK: - Making ViewModel from PaymentInstrumentYandexMoneyLinkedBankCard

    private static func makePaymentMethodViewModel(_ paymentOption: PaymentInstrumentYandexMoneyLinkedBankCard)
            -> PaymentMethodViewModel {
        return PaymentMethod(name: makePaymentMethodViewModelName(paymentOption),
                             image: makePaymentMethodViewModelImage(paymentOption),
                             balance: nil)
    }

    private static func makePaymentMethodViewModelName(_ paymentOption: PaymentInstrumentYandexMoneyLinkedBankCard)
            -> String {
        return paymentOption.cardName ?? makeMaskedPan(paymentOption.cardMask)
    }

    // swiftlint:disable cyclomatic_complexity
    private static func makePaymentMethodViewModelImage(_ paymentOption: PaymentInstrumentYandexMoneyLinkedBankCard)
            -> UIImage {
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

    private static func makePaymentMethodViewModel(_ paymentMethodType: PaymentMethodType) -> PaymentMethodViewModel {
        return PaymentMethod(name: makePaymentMethodViewModelName(paymentMethodType),
                             image: makePaymentMethodViewModelImage(paymentMethodType),
                             balance: nil)
    }

    private static func makePaymentMethodViewModelName(_ paymentMethodType: PaymentMethodType) -> String {
        let name: String
        switch paymentMethodType {
        case .bankCard:
            name = §PaymentMethodResources.Localized.bankCard
        case .yandexMoney:
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

    private static func makePaymentMethodViewModelImage(_ paymentMethodType: PaymentMethodType) -> UIImage {
        let image: UIImage
        switch paymentMethodType {
        case .bankCard:
            image = PaymentMethodResources.Image.unknown
        case .yandexMoney:
            image = PaymentMethodResources.Image.yandexWallet
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
