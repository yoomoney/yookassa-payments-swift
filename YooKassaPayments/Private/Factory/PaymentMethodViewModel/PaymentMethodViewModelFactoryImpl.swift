import class UIKit.UIImage
import YooKassaPaymentsApi

final class PaymentMethodViewModelFactoryImpl {

    // MARK: - Init data

    private let bankSettingsService: BankSettingsService
    private let configMediator: ConfigMediator

    // MARK: - Init

    init(
        bankSettingsService: BankSettingsService,
        configMediator: ConfigMediator
    ) {
        self.bankSettingsService = bankSettingsService
        self.configMediator = configMediator
    }

    // MARK: - Stored properties

    lazy var balanceNumberFormatter: NumberFormatter = {
        $0.locale = .current
        $0.numberStyle = .currency
        return $0
    }(NumberFormatter())

    func makeMaskedPan(_ cardMask: String) -> String {
        let pan = String(cardMask.suffix(8))
        let replacedPan = replaceBullets(pan)
        return replacedPan.chunks(of: 4).joined(separator: " ")
    }
}

// MARK: - PaymentMethodViewModelFactory

extension PaymentMethodViewModelFactoryImpl: PaymentMethodViewModelFactory {
    func yooLogoImage() -> UIImage {
        configMediator.asset(for: .logo)
    }

    // MARK: - Transform ViewModel from PaymentOption

    func makePaymentMethodViewModels(
        _ paymentOptions: [PaymentOption],
        walletDisplayName: String?
    ) -> (models: [PaymentMethodViewModel], indexMap: ([Int: Int])) {
        var map: [Int: Int] = [:]
        let viewModels = paymentOptions
            .map { element -> [PaymentMethodViewModel] in
                return makePaymentMethodViewModel(
                    paymentOption: element,
                    walletDisplayName: walletDisplayName
                )
            }
        var index = 0
        viewModels.enumerated().forEach { enumerated in
            enumerated.element.forEach { _ in
                map[index] = enumerated.offset
                index += 1
            }
        }
        return (viewModels.flatMap { $0 }, map)
    }

    func makePaymentMethodViewModel(
        paymentOption: PaymentInstrumentYooMoneyWallet,
        walletDisplayName: String?
    ) -> PaymentMethodViewModel {
        makePaymentMethodViewModel(
            paymentOption,
            walletDisplayName: walletDisplayName
        )
    }

    // MARK: - Additional protocol methods

    func replaceBullets(_ pan: String) -> String {
        return pan.replacingOccurrences(of: "*", with: "•")
    }

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
        first6Digits: String?,
        bankCardType: BankCardType
    ) -> UIImage {
        let image: UIImage
        if
            let first6Digits = first6Digits,
            let bankSettings = bankSettingsService.bankSettings(first6Digits)
        {
            image = UIImage.named(bankSettings.logoName)
        } else if
            let first6 = first6Digits,
            let existing = BankCardImageFactoryAssembly.makeFactory().makeImage(first6)
        {
            image = existing
        } else {
            image = makeBankCardImage(cardType: bankCardType)
        }

        return image
    }
}

// MARK: - Making ViewModel from PaymentInstrumentYooMoneyWallet

private extension PaymentMethodViewModelFactoryImpl {
    func makePaymentMethodViewModel(
        paymentOption: PaymentOption,
        walletDisplayName: String?
    ) -> [PaymentMethodViewModel] {
        switch paymentOption {
        case let paymentOption as PaymentInstrumentYooMoneyWallet:
            return [makePaymentMethodViewModel(paymentOption, walletDisplayName: walletDisplayName)]
        case let paymentOption as PaymentInstrumentYooMoneyLinkedBankCard:
            return [makePaymentMethodViewModel(paymentOption)]
        default:
            switch paymentOption.paymentMethodType {
            case .bankCard:
                guard let option = paymentOption as? PaymentOptionBankCard else { fallthrough }
                var cards = option.paymentInstruments?.map { card in
                    PaymentMethodViewModel(
                        id: card.paymentInstrumentId,
                        isShopLinkedCard: true,
                        image: makeBankCardImage(
                            first6Digits: card.first6,
                            bankCardType: card.cardType
                        ),
                        title: replaceBullets("**** \(card.last4)"),
                        subtitle: PaymentMethodResources.Localized.linkedCard,
                        hasActions: true
                    )
                } ?? []
                cards.append(
                    PaymentMethodViewModel(
                        id: nil,
                        isShopLinkedCard: false,
                        image: makePaymentMethodTypeImage(option.paymentMethodType),
                        title: makePaymentMethodTypeTitle(option.paymentMethodType),
                        subtitle: nil
                    )
                )
                return cards
            default:
                return [
                    PaymentMethodViewModel(
                        id: nil,
                        isShopLinkedCard: false,
                        image: makePaymentMethodTypeImage(paymentOption.paymentMethodType),
                        title: makePaymentMethodTypeTitle(paymentOption.paymentMethodType),
                        subtitle: nil
                    ),
                ]
            }
        }
    }

    func makePaymentMethodViewModel(
        _ paymentOption: PaymentInstrumentYooMoneyWallet,
        walletDisplayName: String?
    ) -> PaymentMethodViewModel {
        return PaymentMethodViewModel(
            id: nil,
            isShopLinkedCard: false,
            image: makePaymentMethodTypeImage(.yooMoney),
            title: walletDisplayName ?? paymentOption.accountId,
            subtitle: makeBalanceText(paymentOption.balance)
        )
    }

    func makeBalanceText(
        _ balance: YooKassaPaymentsApi.MonetaryAmount
    ) -> String? {
        let amount = MonetaryAmountFactory.makeAmount(balance)
        balanceNumberFormatter.currencySymbol = amount.currency.symbol
        return balanceNumberFormatter.string(for: amount.value)
    }
}

// MARK: - Making ViewModel from PaymentInstrumentYooMoneyLinkedBankCard

private extension PaymentMethodViewModelFactoryImpl {
    func makePaymentMethodViewModel(
        _ paymentOption: PaymentInstrumentYooMoneyLinkedBankCard
    ) -> PaymentMethodViewModel {
        return PaymentMethodViewModel(
            id: nil,
            isShopLinkedCard: false,
            image: makeBankCardImage(paymentOption),
            title: makeBankCardTitle(paymentOption),
            subtitle: makeBankCardSubtitle(paymentOption),
            hasActions: true
        )
    }

    func makeBankCardTitle(
        _ paymentOption: PaymentInstrumentYooMoneyLinkedBankCard
    ) -> String {
        return paymentOption.cardName
            ?? makeMaskedPan(paymentOption.cardMask)
    }

    func makeBankCardSubtitle(
        _ paymentOption: PaymentInstrumentYooMoneyLinkedBankCard
    ) -> String {
        return PaymentMethodResources.Localized.yooMoneyCard
    }
}

// MARK: - Making ViewModel from PaymentMethodType

private extension PaymentMethodViewModelFactoryImpl {
    func makePaymentMethodTypeTitle(_ paymentMethodType: YooKassaPaymentsApi.PaymentMethodType) -> String {
        let kind: Config.PaymentMethod.Kind
        switch paymentMethodType {
        case .bankCard: kind = .bankCard
        case .yooMoney: kind = .yoomoney
        case .applePay: kind = .applePay
        case .sberbank: kind = .sberbank
        default:
            assertionFailure("Unsupported PaymentMethodType")
            return "Unsupported"
        }
        let defaultTitle: String
        switch kind {
        case .bankCard: defaultTitle = PaymentMethodResources.Localized.bankCard
        case .yoomoney: defaultTitle = PaymentMethodResources.Localized.wallet
        case .applePay: defaultTitle = PaymentMethodResources.Localized.applePay
        case .sberbank: defaultTitle = PaymentMethodResources.Localized.sberpay
        case .unknown:
            assertionFailure("Unsupported kind")
            defaultTitle = "Unsupported"
        }
        return configMediator.storedConfig().paymentMethods.first { $0.kind == kind }?.title
            ?? defaultTitle
    }
}

// MARK: - Make Image

private extension PaymentMethodViewModelFactoryImpl {

    func makePaymentMethodTypeImage(
        _ paymentMethodType: YooKassaPaymentsApi.PaymentMethodType
    ) -> UIImage {
        let image: UIImage
        switch paymentMethodType {
        case .bankCard:
            image = configMediator.asset(for: .bankCard)
        case .yooMoney:
            image = configMediator.asset(for: .yoomoney)
        case .applePay:
            image = configMediator.asset(for: .applePay)
        case .sberbank:
            image = configMediator.asset(for: .sberbank)
        default:
            assertionFailure("Unsupported PaymentMethodType")
            image = UIImage()
        }
        return image
    }

    // swiftlint:disable cyclomatic_complexity
    func makeBankCardImage(
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
        @unknown default:
            image = PaymentMethodResources.Image.unknown
        }
        return image
    }
    // swiftlint:enable cyclomatic_complexity
}
