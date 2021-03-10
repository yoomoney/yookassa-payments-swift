import PassKit
import UIKit

enum ApplePayAssembly {
    static func makeModule(
        inputData: ApplePayModuleInputData,
        moduleOutput: ApplePayModuleOutput
    ) -> UIViewController? {
        guard PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: inputData.supportedNetworks),
              let merchantIdentifier = inputData.merchantIdentifier,
              let countryCode = Locale.current.regionCode else {
            return nil
        }

        let paymentRequest = PKPaymentRequest()
        paymentRequest.merchantIdentifier = merchantIdentifier
        paymentRequest.countryCode = countryCode
        paymentRequest.currencyCode = inputData.amount.currency.rawValue
        paymentRequest.supportedNetworks = inputData.supportedNetworks
        paymentRequest.merchantCapabilities = .capability3DS

        let amountValue = inputData.amount.value as NSDecimalNumber
        let shopNameAmount = PKPaymentSummaryItem(
            label: inputData.shopName,
            amount: amountValue
        )
        var feePaymentSummaryItem: PKPaymentSummaryItem?
        let purchaseDescriptionAmount = PKPaymentSummaryItem(
            label: inputData.purchaseDescription,
            amount: amountValue
        )

        if let fee = inputData.fee,
           let service = fee.service {
            let chargeValue = service.charge.value as NSDecimalNumber
            feePaymentSummaryItem = PKPaymentSummaryItem(label: §Localized.fee, amount: chargeValue)
            purchaseDescriptionAmount.amount = (inputData.amount.value - service.charge.value) as NSDecimalNumber
        }

        paymentRequest.paymentSummaryItems = [
            purchaseDescriptionAmount, feePaymentSummaryItem, shopNameAmount,
        ].compactMap { $0 }

        let authorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
        authorizationViewController?.delegate = moduleOutput

        return authorizationViewController
    }
}

// MARK: - Localized

private extension ApplePayAssembly {
    enum Localized: String {
        case fee = "ApplePayContract.fee"
    }
}
