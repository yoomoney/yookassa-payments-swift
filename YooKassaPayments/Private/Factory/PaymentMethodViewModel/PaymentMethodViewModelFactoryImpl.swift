import class UIKit.UIImage
import YooKassaPaymentsApi

final class PaymentMethodViewModelFactoryImpl {

    // MARK: - Init data

    private let bankSettingsService: BankSettingsService

    // MARK: - Init

    init(
        bankSettingsService: BankSettingsService
    ) {
        self.bankSettingsService = bankSettingsService
    }

    // MARK: - Stored properties

    lazy var balanceNumberFormatter: NumberFormatter = {
        $0.locale = .current
        $0.numberStyle = .currency
        return $0
    }(NumberFormatter())
}

// MARK: - PaymentMethodViewModelFactory

extension PaymentMethodViewModelFactoryImpl: PaymentMethodViewModelFactory {

    // MARK: - Replace bullets

    func replaceBullets(_ pan: String) -> String {
        return pan.replacingOccurrences(of: "*", with: "•")
    }

    // MARK: - Transform ViewModel from PaymentOption

    func makePaymentMethodViewModel(
        paymentOption: PaymentOption,
        walletDisplayName: String?
    ) -> PaymentMethodViewModel {
        let viewModel: PaymentMethodViewModel
        switch paymentOption {
        case let paymentOption as PaymentInstrumentYooMoneyWallet:
            viewModel = makePaymentMethodViewModel(
                paymentOption,
                walletDisplayName: walletDisplayName
            )
        case let paymentOption as PaymentInstrumentYooMoneyLinkedBankCard:
            viewModel = makePaymentMethodViewModel(paymentOption)
        default:
            viewModel = makePaymentMethodViewModel(paymentOption.paymentMethodType)
        }
        return viewModel
    }

    func makePaymentMethodViewModel(
        paymentOption: PaymentOption
    ) -> PaymentMethodViewModel {
        let viewModel: PaymentMethodViewModel
        switch paymentOption {
        case let paymentOption as PaymentInstrumentYooMoneyWallet:
            viewModel = makePaymentMethodViewModel(
                paymentOption
            )
        case let paymentOption as PaymentInstrumentYooMoneyLinkedBankCard:
            viewModel = makePaymentMethodViewModel(paymentOption)
        default:
            viewModel = makePaymentMethodViewModel(paymentOption.paymentMethodType)
        }
        return viewModel
    }

    // MARK: - Making ViewModel from PaymentInstrumentYooMoneyWallet

    private func makePaymentMethodViewModel(
        _ paymentOption: PaymentInstrumentYooMoneyWallet,
        walletDisplayName: String?
    ) -> PaymentMethodViewModel {
        return PaymentMethodViewModel(
            image: PaymentMethodResources.Image.yooMoney,
            title: walletDisplayName ?? paymentOption.accountId,
            subtitle: makeBalanceText(paymentOption.balance)
        )
    }

    private func makePaymentMethodViewModel(
        _ paymentOption: PaymentInstrumentYooMoneyWallet
    ) -> PaymentMethodViewModel {
        return PaymentMethodViewModel(
            image: PaymentMethodResources.Image.yooMoney,
            title: §PaymentMethodResources.Localized.wallet,
            subtitle: makeBalanceText(paymentOption.balance)
        )
    }

    private func makeBalanceText(
        _ balance: YooKassaPaymentsApi.MonetaryAmount
    ) -> String? {
        let amount = MonetaryAmountFactory.makeAmount(balance)
        balanceNumberFormatter.currencySymbol = amount.currency.symbol
        return balanceNumberFormatter.string(for: amount.value)
    }

    // MARK: - Making ViewModel from PaymentInstrumentYooMoneyLinkedBankCard

    private func makePaymentMethodViewModel(
        _ paymentOption: PaymentInstrumentYooMoneyLinkedBankCard
    ) -> PaymentMethodViewModel {
        return PaymentMethodViewModel(
            image: makeBankCardImage(paymentOption),
            title: makeBankCardTitle(paymentOption),
            subtitle: makeBankCardSubtitle(paymentOption)
        )
    }

    private func makeBankCardTitle(
        _ paymentOption: PaymentInstrumentYooMoneyLinkedBankCard
    ) -> String {
        return paymentOption.cardName
            ?? makeMaskedPan(paymentOption.cardMask)
    }

    private func makeBankCardSubtitle(
        _ paymentOption: PaymentInstrumentYooMoneyLinkedBankCard
    ) -> String? {
        guard paymentOption.cardName != nil else {
            return nil
        }

        return makeMaskedPan(paymentOption.cardMask)
    }

    private func makeMaskedPan(_ cardMask: String) -> String {
        let pan = String(cardMask.suffix(8))
        let replacedPan = replaceBullets(pan)
        return replacedPan.chunks(of: 4).joined(separator: " ")
    }

    // MARK: - Making ViewModel from PaymentMethodType

    func makePaymentMethodViewModel(
        _ paymentMethodType: YooKassaPaymentsApi.PaymentMethodType
    ) -> PaymentMethodViewModel {
        return PaymentMethodViewModel(
            image: makePaymentMethodTypeImage(paymentMethodType),
            title: makePaymentMethodTypeTitle(paymentMethodType),
            subtitle: nil
        )
    }

    private func makePaymentMethodTypeTitle(
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
    
    // MARK: - Make Image
    
    func makeBankCardImage(
        _ paymentOption: PaymentInstrumentYooMoneyLinkedBankCard
    ) -> UIImage {
        if let bankSettings = bankSettingsService.bankSettings(paymentOption.cardMask) {
            return UIImage.named(bankSettings.logoName)
        } else {
            return makeBankCardImage(
                cardType: paymentOption.cardType
            )
        }
    }
    
    
    func makeBankCardImage(
        _ paymentMethodBankCard: PaymentMethodBankCard
    ) -> UIImage {
        if let bankSettings = bankSettingsService.bankSettings(paymentMethodBankCard.first6) {
            return UIImage.named(bankSettings.logoName)
        } else {
            return makeBankCardImage(
                cardType: paymentMethodBankCard.cardType
            )
        }
    }
    
    func makePaymentMethodTypeImage(
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

    private func makeBankCardImage(
        cardType: BankCardType
    ) -> UIImage {
        let image: UIImage
        switch cardType {
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
}
