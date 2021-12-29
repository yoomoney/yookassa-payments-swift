import Foundation
import enum YooKassaPaymentsApi.SavePaymentMethod

enum PaymentRecurrencyAndDataSavingSectionFactory {
    static func make(
        clientSavePaymentMethod: SavePaymentMethod,
        apiSavePaymentMethod: YooKassaPaymentsApi.SavePaymentMethod,
        canSavePaymentInstrument: Bool,
        texts: Config.SavePaymentMethodOptionTexts,
        output: PaymentRecurrencyAndDataSavingSectionOutput
    ) -> PaymentRecurrencyAndDataSavingSection? {
        let view: PaymentRecurrencyAndDataSavingSection?
        switch (clientSavePaymentMethod, apiSavePaymentMethod, canSavePaymentInstrument) {
        case (.on, .forbidden, false), (.off, .forbidden, false), (.userSelects, .forbidden, false),
             (.off, .allowed, false):
        view = nil

        case (.off, .forbidden, true), (.off, .allowed, true), (.userSelects, .forbidden, true):
        view = PaymentRecurrencyAndDataSavingSection(mode: .savePaymentData, texts: texts)

        case (.userSelects, .allowed, false):
        view = PaymentRecurrencyAndDataSavingSection(mode: .allowRecurring, texts: texts)

        case (.userSelects, .allowed, true):
        view = PaymentRecurrencyAndDataSavingSection(mode: .allowRecurringAndSaveData, texts: texts)

        case (.on, .allowed, true):
        view = PaymentRecurrencyAndDataSavingSection(mode: .requiredRecurringAndSaveData, texts: texts)

        case (.on, .allowed, false):
        view = PaymentRecurrencyAndDataSavingSection(mode: .requiredRecurring, texts: texts)

        case (.on, .forbidden, true):
        view = PaymentRecurrencyAndDataSavingSection(mode: .savePaymentData, texts: texts)

        default:
        view = nil
        }
        view?.output = output
        return view
    }

    static func make(
        mode: PaymentRecurrencyAndDataSavingSection.Mode,
        texts: Config.SavePaymentMethodOptionTexts,
        output: PaymentRecurrencyAndDataSavingSectionOutput
    ) -> PaymentRecurrencyAndDataSavingSection {
        let view = PaymentRecurrencyAndDataSavingSection(mode: mode, texts: texts)
        view.output = output
        return view
    }
}
