import protocol PassKit.PKPaymentAuthorizationViewControllerDelegate

protocol ApplePayModuleInput: class {}

protocol ApplePayModuleOutput: PKPaymentAuthorizationViewControllerDelegate {
    func didPresentApplePayModule()
    func didFailPresentApplePayModule()
}
