import YandexCheckoutPaymentsApi

enum RecurringViewModelFactory {
    static func makeRecurringViewModel(
        _ paymentOption: PaymentOption,
        _ recurring: Recurring
    ) -> RecurringViewModel? {

        let recurringViewModel: RecurringViewModel?
        if paymentOption.savePaymentMethodAllowed {
            switch recurring {
            case .force:
                guard let textValue = makeTextValue(paymentOption, recurring) else {
                    return nil
                }
                let strictRecurringViewModel = StrictRecurringViewModel(
                    text: textValue.text,
                    hyperText: textValue.hyperText
                )
                recurringViewModel = .strict(strictRecurringViewModel)
            case .disable:
                recurringViewModel = nil
            case .userPriority:
                guard let textValue = makeTextValue(paymentOption, recurring) else {
                    return nil
                }
                let switcherRecurringViewModel = SwitcherRecurringViewModel(
                    state: true,
                    text: textValue.text,
                    hyperText: textValue.hyperText
                )
                recurringViewModel = .switcher(switcherRecurringViewModel)
            }
        } else {
            recurringViewModel = nil
        }
        return recurringViewModel
    }

    static func makeRecurringViewModel(
        _ recurring: Recurring
    ) -> RecurringViewModel? {
        let recurringViewModel: RecurringViewModel?
        switch recurring {
        case .userPriority:
            let textValue = (
                text: §Localized.BankCard.UserPriority.text,
                hyperText: §Localized.BankCard.UserPriority.hyperText
            )
            let switcherRecurringViewModel = SwitcherRecurringViewModel(
                state: true,
                text: textValue.text,
                hyperText: textValue.hyperText
            )
            recurringViewModel = .switcher(switcherRecurringViewModel)
        case .force:
            let textValue = (
                text: §Localized.BankCard.Force.text,
                hyperText: §Localized.BankCard.Force.hyperText
            )
            let strictRecurringViewModel = StrictRecurringViewModel(
                text: textValue.text,
                hyperText: textValue.hyperText
            )
            recurringViewModel = .strict(strictRecurringViewModel)
        case .disable:
            recurringViewModel = nil
        }
        return recurringViewModel
    }

    private static func makeTextValue(
        _ paymentOption: PaymentOption,
        _ recurring: Recurring
    ) -> (text: String, hyperText: String)? {
        if paymentOption is PaymentInstrumentYandexMoneyWallet {
            switch recurring {
            case .userPriority:
                return (
                    text: §Localized.Wallet.UserPriority.text,
                    hyperText: §Localized.Wallet.UserPriority.hyperText
                )
            case .force:
                return (
                    text: §Localized.Wallet.Force.text,
                    hyperText: §Localized.Wallet.Force.hyperText
                )
            default:
                assertionFailure("Unsupported `Recurring` for text value")
                return nil
            }
        } else if paymentOption.paymentMethodType == .bankCard {
            switch recurring {
            case .userPriority:
                return (
                    text: §Localized.BankCard.UserPriority.text,
                    hyperText: §Localized.BankCard.UserPriority.hyperText
                )
            case .force:
                return (
                    text: §Localized.BankCard.Force.text,
                    hyperText: §Localized.BankCard.Force.hyperText
                )
            default:
                assertionFailure("Unsupported `Recurring` for text value")
                return nil
            }
        } else {
            assertionFailure("Unsupported PaymentMethodType for RecurringViewModel text")
            return nil
        }
    }
}

// MARK: - Localized

private enum Localized {
    enum Wallet {
        enum UserPriority: String {
            case text = "Recurring.Wallet.UserPriority.Text"
            case hyperText = "Recurring.Wallet.UserPriority.hyperText"
        }
        enum Force: String {
            case text = "Recurring.Wallet.Force.Text"
            case hyperText = "Recurring.Wallet.Force.hyperText"
        }
    }

    enum BankCard {
        enum UserPriority: String {
            case text = "Recurring.BankCard.UserPriority.Text"
            case hyperText = "Recurring.BankCard.UserPriority.hyperText"
        }
        enum Force: String {
            case text = "Recurring.BankCard.Force.Text"
            case hyperText = "Recurring.BankCard.Force.hyperText"
        }
    }
}
