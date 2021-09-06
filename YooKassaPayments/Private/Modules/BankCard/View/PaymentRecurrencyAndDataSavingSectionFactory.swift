import Foundation
import enum YooKassaPaymentsApi.SavePaymentMethod

enum PaymentRecurrencyAndDataSavingSectionFactory {
    static func make(
        clientSavePaymentMethod: SavePaymentMethod,
        apiSavePaymentMethod: YooKassaPaymentsApi.SavePaymentMethod,
        canSavePaymentInstrument: Bool,
        output: PaymentRecurrencyAndDataSavingSectionOutput
    ) -> PaymentRecurrencyAndDataSavingSection? {
        let view: PaymentRecurrencyAndDataSavingSection?
        switch (clientSavePaymentMethod, apiSavePaymentMethod, canSavePaymentInstrument) {
        case (.on, .forbidden, false), (.off, .forbidden, false), (.userSelects, .forbidden, false),
             (.off, .allowed, false):
        view = nil

        case (.off, .forbidden, true), (.off, .allowed, true), (.userSelects, .forbidden, true):
        view = PaymentRecurrencyAndDataSavingSection(mode: .savePaymentData)

        case (.userSelects, .allowed, false):
        view = PaymentRecurrencyAndDataSavingSection(mode: .allowRecurring)

        case (.userSelects, .allowed, true):
        view = PaymentRecurrencyAndDataSavingSection(mode: .allowRecurringAndSaveData)

        case (.on, .allowed, true):
        view = PaymentRecurrencyAndDataSavingSection(mode: .requiredRecurringAndSaveData)

        case (.on, .allowed, false):
        view = PaymentRecurrencyAndDataSavingSection(mode: .requiredRecurring)

        case (.on, .forbidden, true):
        view = PaymentRecurrencyAndDataSavingSection(mode: .savePaymentData)

        default:
        view = nil
        }
        view?.output = output
        return view
    }

    static func make(
        mode: PaymentRecurrencyAndDataSavingSection.Mode,
        output: PaymentRecurrencyAndDataSavingSectionOutput
    ) -> PaymentRecurrencyAndDataSavingSection {
        let view = PaymentRecurrencyAndDataSavingSection(mode: mode)
        view.output = output
        return view
    }
}
