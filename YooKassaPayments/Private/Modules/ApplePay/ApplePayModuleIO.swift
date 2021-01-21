import PassKit
import YooKassaPaymentsApi

struct ApplePayModuleInputData {
    let merchantIdentifier: String?
    let amount: Amount
    let shopName: String
    let purchaseDescription: String
    let supportedNetworks: [PKPaymentNetwork]
    let fee: YooKassaPaymentsApi.Fee?
}

protocol ApplePayModuleInput: class {}

protocol ApplePayModuleOutput: PKPaymentAuthorizationViewControllerDelegate {
    func didPresentApplePayModule()
    func didFailPresentApplePayModule()
}
