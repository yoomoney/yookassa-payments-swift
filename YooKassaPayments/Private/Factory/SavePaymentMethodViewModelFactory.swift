import YooKassaPaymentsApi

enum SavePaymentMethodViewModelFactory {

    /// Use for .tokenization TokenizationFlow
    static func makeSavePaymentMethodViewModel(
        _ paymentOption: PaymentOption,
        _ savePaymentMethod: SavePaymentMethod,
        initialState: Bool
    ) -> SavePaymentMethodViewModel? {
        let savePaymentMethodViewModel: SavePaymentMethodViewModel?
        if paymentOption.savePaymentMethod == .allowed {
            switch savePaymentMethod {
            case .on:
                guard let textValue = makeTextValue(paymentOption, savePaymentMethod) else {
                    return nil
                }
                let strictSavePaymentMethodViewModel = StrictSavePaymentMethodViewModel(
                    text: textValue.text,
                    hyperText: textValue.hyperText
                )
                savePaymentMethodViewModel = .strict(strictSavePaymentMethodViewModel)
            case .off:
                savePaymentMethodViewModel = nil
            case .userSelects:
                guard let textValue = makeTextValue(paymentOption, savePaymentMethod) else {
                    return nil
                }
                let switcherSavePaymentMethodViewModel = SwitcherSavePaymentMethodViewModel(
                    state: initialState,
                    text: textValue.text,
                    hyperText: textValue.hyperText
                )
                savePaymentMethodViewModel = .switcher(switcherSavePaymentMethodViewModel)
            }
        } else {
            savePaymentMethodViewModel = nil
        }
        return savePaymentMethodViewModel
    }

    /// Use for .bankCardRepeat TokenizationFlow
    static func makeSavePaymentMethodViewModel(
        _ savePaymentMethod: SavePaymentMethod,
        initialState: Bool
    ) -> SavePaymentMethodViewModel? {
        let savePaymentMethodViewModel: SavePaymentMethodViewModel?
        switch savePaymentMethod {
        case .userSelects:
            let textValue = (
                text: Localized.BankCard.UserPriority.text,
                hyperText: Localized.BankCard.UserPriority.hyperText
            )
            let switcherSavePaymentMethodViewModel = SwitcherSavePaymentMethodViewModel(
                state: initialState,
                text: textValue.text,
                hyperText: textValue.hyperText
            )
            savePaymentMethodViewModel = .switcher(switcherSavePaymentMethodViewModel)
        case .on:
            let textValue = (
                text: Localized.BankCard.Force.text,
                hyperText: Localized.BankCard.Force.hyperText
            )
            let strictSavePaymentMethodViewModel = StrictSavePaymentMethodViewModel(
                text: textValue.text,
                hyperText: textValue.hyperText
            )
            savePaymentMethodViewModel = .strict(strictSavePaymentMethodViewModel)
        case .off:
            savePaymentMethodViewModel = nil
        }
        return savePaymentMethodViewModel
    }

    private static func makeTextValue(
        _ paymentOption: PaymentOption,
        _ savePaymentMethod: SavePaymentMethod
    ) -> (text: String, hyperText: String)? {
        if paymentOption is PaymentInstrumentYooMoneyWallet {
            switch savePaymentMethod {
            case .userSelects:
                return (
                    text: Localized.Wallet.UserPriority.text,
                    hyperText: Localized.Wallet.UserPriority.hyperText
                )
            case .on:
                return (
                    text: Localized.Wallet.Force.text,
                    hyperText: Localized.Wallet.Force.hyperText
                )
            default:
                return nil
            }
        } else if paymentOption.paymentMethodType == .bankCard
            || paymentOption is PaymentInstrumentYooMoneyLinkedBankCard
            || paymentOption.paymentMethodType == .applePay {
            switch savePaymentMethod {
            case .userSelects:
                return (
                    text: Localized.BankCard.UserPriority.text,
                    hyperText: Localized.BankCard.UserPriority.hyperText
                )
            case .on:
                return (
                    text: Localized.BankCard.Force.text,
                    hyperText: Localized.BankCard.Force.hyperText
                )
            default:
                return nil
            }
        } else {
            return nil
        }
    }
}

// MARK: - Localized

private enum Localized {
    enum Wallet {
        enum UserPriority {
            static let text = NSLocalizedString(
                "SavePaymentMethod.Wallet.UserPriority.Text",
                bundle: Bundle.framework,
                value: "Разрешить магазину",
                comment: "Текст `Разрешить магазину` https://yadi.sk/i/o89CnEUSmNsM7g"
            )
            static let hyperText = NSLocalizedString(
                "SavePaymentMethod.Wallet.UserPriority.hyperText",
                bundle: Bundle.framework,
                value: "списывать деньги без моего участия",
                comment: "Текст `списывать деньги без моего участия` https://yadi.sk/i/o89CnEUSmNsM7g"
            )
        }
        enum Force {
            static let text = NSLocalizedString(
                "SavePaymentMethod.Wallet.Force.Text",
                bundle: Bundle.framework,
                value: "После оплаты привяжем кошелёк: магазин сможет",
                comment: "Текст `После оплаты привяжем кошелёк: магазин сможет` https://yadi.sk/i/rFEZPSdXTgV1bw"
            )
            static let hyperText = NSLocalizedString(
                "SavePaymentMethod.Wallet.Force.hyperText",
                bundle: Bundle.framework,
                value: "списывать деньги без вашего участия",
                comment: "Текст `списывать деньги без вашего участия` https://yadi.sk/i/rFEZPSdXTgV1bw"
            )
        }
    }

    enum BankCard {
        enum UserPriority {
            static let text = NSLocalizedString(
                "SavePaymentMethod.BankCard.UserPriority.Text",
                bundle: Bundle.framework,
                value: "Привязать карту и",
                comment: "Текст `Привязать карту и` https://yadi.sk/i/Z2oi1Uun7nS-jA"
            )
            static let hyperText = NSLocalizedString(
                "SavePaymentMethod.BankCard.UserPriority.hyperText",
                bundle: Bundle.framework,
                value: "списывать деньги по запросу магазина",
                comment: "Текст `списывать деньги по запросу магазина` https://yadi.sk/i/Z2oi1Uun7nS-jA"
            )
        }
        enum Force {
            static let text = NSLocalizedString(
                "SavePaymentMethod.BankCard.Force.Text",
                bundle: Bundle.framework,
                value: "После оплаты привяжем карту, чтобы",
                comment: "Текст `После оплаты привяжем карту, чтобы` https://yadi.sk/i/_PWhW8MwuxCopQ"
            )
            static let hyperText = NSLocalizedString(
                "SavePaymentMethod.BankCard.Force.hyperText",
                bundle: Bundle.framework,
                value: "списывать деньги по запросу магазина",
                comment: "Текст `списывать деньги по запросу магазина` https://yadi.sk/i/_PWhW8MwuxCopQ"
            )
        }
    }
}
