import PassKit

struct ApplePayModuleInputData {
    let merchantIdentifier: String?
    let amount: Amount
    let shopName: String
    let purchaseDescription: String
    let supportedNetworks: [PKPaymentNetwork]
    let fee: Fee?
}

protocol ApplePayModuleInput: class {}

protocol ApplePayModuleOutput: PKPaymentAuthorizationViewControllerDelegate {
    func didPresentApplePayModule()
    func didFailPresentApplePayModule()
}
