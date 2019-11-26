import YandexCheckoutPaymentsApi

enum SavePaymentMethodViewModelFactory {

    /// Use for .tokenization TokenizationFlow
    static func makeSavePaymentMethodViewModel(
        _ paymentOption: PaymentOption,
        _ savePaymentMethod: SavePaymentMethod,
        initialState: Bool
    ) -> SavePaymentMethodViewModel? {

        let savePaymentMethodViewModel: SavePaymentMethodViewModel?
        if paymentOption.savePaymentMethodAllowed {
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
                text: §Localized.BankCard.UserPriority.text,
                hyperText: §Localized.BankCard.UserPriority.hyperText
            )
            let switcherSavePaymentMethodViewModel = SwitcherSavePaymentMethodViewModel(
                state: initialState,
                text: textValue.text,
                hyperText: textValue.hyperText
            )
            savePaymentMethodViewModel = .switcher(switcherSavePaymentMethodViewModel)
        case .on:
            let textValue = (
                text: §Localized.BankCard.Force.text,
                hyperText: §Localized.BankCard.Force.hyperText
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
        if paymentOption is PaymentInstrumentYandexMoneyWallet {
            switch savePaymentMethod {
            case .userSelects:
                return (
                    text: §Localized.Wallet.UserPriority.text,
                    hyperText: §Localized.Wallet.UserPriority.hyperText
                )
            case .on:
                return (
                    text: §Localized.Wallet.Force.text,
                    hyperText: §Localized.Wallet.Force.hyperText
                )
            default:
                return nil
            }
        } else if paymentOption.paymentMethodType == .bankCard
            || paymentOption is PaymentInstrumentYandexMoneyLinkedBankCard
            || paymentOption.paymentMethodType == .applePay {
            switch savePaymentMethod {
            case .userSelects:
                return (
                    text: §Localized.BankCard.UserPriority.text,
                    hyperText: §Localized.BankCard.UserPriority.hyperText
                )
            case .on:
                return (
                    text: §Localized.BankCard.Force.text,
                    hyperText: §Localized.BankCard.Force.hyperText
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
        enum UserPriority: String {
            case text = "SavePaymentMethod.Wallet.UserPriority.Text"
            case hyperText = "SavePaymentMethod.Wallet.UserPriority.hyperText"
        }
        enum Force: String {
            case text = "SavePaymentMethod.Wallet.Force.Text"
            case hyperText = "SavePaymentMethod.Wallet.Force.hyperText"
        }
    }

    enum BankCard {
        enum UserPriority: String {
            case text = "SavePaymentMethod.BankCard.UserPriority.Text"
            case hyperText = "SavePaymentMethod.BankCard.UserPriority.hyperText"
        }
        enum Force: String {
            case text = "SavePaymentMethod.BankCard.Force.Text"
            case hyperText = "SavePaymentMethod.BankCard.Force.hyperText"
        }
    }
}
