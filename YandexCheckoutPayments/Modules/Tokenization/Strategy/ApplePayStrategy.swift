import PassKit
import UIKit
import YandexCheckoutPaymentsApi

final class ApplePayStrategy: NSObject {

    fileprivate enum PaymentResult {
        case success
        case failed
    }

    weak var output: TokenizationStrategyOutput?
    weak var contractStateHandler: ContractStateHandler?

    fileprivate let paymentOption: PaymentOption
    fileprivate let analyticsService: AnalyticsProcessing
    fileprivate let analyticsProvider: AnalyticsProviding

    fileprivate weak var paymentMethodsModuleInput: PaymentMethodsModuleInput?
    fileprivate var paymentResult: PaymentResult = .failed

    init(paymentOption: PaymentOption,
         paymentMethodsModuleInput: PaymentMethodsModuleInput?,
         analyticsService: AnalyticsProcessing,
         analyticsProvider: AnalyticsProviding) throws {
        guard case .applePay = paymentOption.paymentMethodType else {
            throw TokenizationStrategyError.incorrectPaymentOptions
        }
        self.paymentOption = paymentOption
        self.paymentMethodsModuleInput = paymentMethodsModuleInput
        self.analyticsService = analyticsService
        self.analyticsProvider = analyticsProvider
    }
}

// MARK: - TokenizationStrategyInput

extension ApplePayStrategy: TokenizationStrategyInput {

    func beginProcess() {
        output?.presentApplePay()
    }

    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController,
                                            didAuthorizePayment payment: PKPayment,
                                            completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        paymentResult = .success

        let tokenizeData: TokenizeData = .applePay(paymentData: payment.token.paymentData.base64EncodedString())
        output?.tokenize(tokenizeData)
        completion(.success)
    }

    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        if case .failed = paymentResult {
            output?.presentPaymentMethodsModule()
        }
    }

    func didPresentApplePayModule() {

        DispatchQueue.global().async { [weak self] in
            guard let strongSelf = self else { return }
            let (authType, _) = strongSelf.analyticsProvider.makeTypeAnalyticsParameters()
            let event: AnalyticsEvent = .screenPaymentContract(authType: authType, scheme: .applePay)
            strongSelf.analyticsService.trackEvent(event)
        }
    }

    func didFailPresentApplePayModule() {
        trackScreenErrorAnalytics()
        paymentMethodsModuleInput?.showPlaceholder(message: §Localized.applePayUnavailableTitle)
    }

    func failTokenizeData(_ error: Error) {
        trackScreenErrorAnalytics()
        output?.presentErrorWithMessage(§Localized.Error.failTokenizeData)
    }

    private func trackScreenErrorAnalytics() {

        DispatchQueue.global().async { [weak self] in
            guard let strongSelf = self else { return }
            let (authType, _) = strongSelf.analyticsProvider.makeTypeAnalyticsParameters()
            let event: AnalyticsEvent = .screenError(authType: authType, scheme: .applePay)
            strongSelf.analyticsService.trackEvent(event)
        }
    }

    func didPressSubmitButton(on module: ContractModuleInput) {}
    func didLoginInYandexMoney(_ response: YamoneyLoginResponse) {}
    func failLoginInYandexMoney(_ error: Error) {}
    func failResendSmsCode(_ error: Error) {}
    func didPressLogout() {}

    func yamoneyAuthParameters(_ module: YamoneyAuthParametersModuleInput,
                               loginWithReusableToken isReusableToken: Bool) {}
    func bankCardDataInputModule(_ module: BankCardDataInputModuleInput,
                                 didPressConfirmButton bankCardData: CardData) {}
    func didPressConfirmButton(on module: BankCardDataInputModuleInput,
                               cvc: String) {}

    func sberbankModule(_ module: SberbankModuleInput, didPressConfirmButton phoneNumber: String) { }
}

// MARK: - Localized

private extension ApplePayStrategy {
    enum Localized: String {
        case applePayUnavailableTitle = "ApplePayUnavailable.title"

        enum Error: String {
            case failTokenizeData = "Error.ApplePayStrategy.failTokenizeData"
        }
    }
}
