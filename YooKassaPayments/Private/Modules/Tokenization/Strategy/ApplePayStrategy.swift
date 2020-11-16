import PassKit
import UIKit
import YooKassaPaymentsApi

final class ApplePayStrategy: NSObject {

    private enum PaymentResult {
        case idle
        case success
        case cancel
    }

    // MARK: - Outputs

    weak var output: TokenizationStrategyOutput?
    weak var contractStateHandler: ContractStateHandler?

    // MARK: - Initial data

    private let paymentOption: PaymentOption
    private let analyticsService: AnalyticsProcessing
    private let analyticsProvider: AnalyticsProviding
    private let inputSavePaymentMethod: SavePaymentMethod

    init(
        paymentOption: PaymentOption,
        paymentMethodsModuleInput: PaymentMethodsModuleInput?,
        analyticsService: AnalyticsProcessing,
        analyticsProvider: AnalyticsProviding,
        savePaymentMethod: Bool,
        inputSavePaymentMethod: SavePaymentMethod
    ) throws {
        guard case .applePay = paymentOption.paymentMethodType else {
            throw TokenizationStrategyError.incorrectPaymentOptions
        }
        self.paymentOption = paymentOption
        self.paymentMethodsModuleInput = paymentMethodsModuleInput
        self.analyticsService = analyticsService
        self.analyticsProvider = analyticsProvider
        self.savePaymentMethod = savePaymentMethod
        self.inputSavePaymentMethod = inputSavePaymentMethod
    }

    // MARK: - Stored data

    private weak var paymentMethodsModuleInput: PaymentMethodsModuleInput?
    private var applePayCompletion: ((PKPaymentAuthorizationStatus) -> Void)?
    private var paymentResult: PaymentResult = .idle

    // MARK: - TokenizationStrategyInput

    var savePaymentMethod: Bool
    var shouldInvalidateTokenizeData = false
}

// MARK: - TokenizationStrategyInput

extension ApplePayStrategy: TokenizationStrategyInput {

    func beginProcess() {
        guard let output = output else { return }

        let feeCondition = paymentOption.fee != nil
        let inputSavePaymentMethodCondition = inputSavePaymentMethod == .userSelects || inputSavePaymentMethod == .on
        let savePaymentMethodCondition = paymentOption.savePaymentMethod == .allowed && inputSavePaymentMethodCondition

        if feeCondition || savePaymentMethodCondition {
            output.presentApplePayContract(paymentOption)
        } else {
            output.presentApplePay(paymentOption)
        }
    }

    func didTokenizeData() {
        guard paymentResult != .cancel else {
            shouldInvalidateTokenizeData = true
            return
        }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.applePayCompletion?(.success)
        }
    }

    func paymentAuthorizationViewController(
        _ controller: PKPaymentAuthorizationViewController,
        didAuthorizePayment payment: PKPayment,
        completion: @escaping (PKPaymentAuthorizationStatus) -> Void
    ) {
        guard paymentResult != .cancel else { return }
        paymentResult = .success
        let tokenizeData: TokenizeData = .applePay(
            paymentData: payment.token.paymentData.base64EncodedString(),
            savePaymentMethod: savePaymentMethod
        )
        applePayCompletion = completion
        output?.tokenize(tokenizeData, paymentOption: paymentOption)
    }

    func paymentAuthorizationViewControllerDidFinish(
        _ controller: PKPaymentAuthorizationViewController
    ) {
        if paymentResult == .idle
            || paymentResult == .success {
            paymentResult = .cancel
            output?.didFinish(on: self)
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
        guard paymentResult != .cancel else { return }
        trackScreenErrorAnalytics()
        paymentMethodsModuleInput?.showPlaceholder(message: §Localized.applePayUnavailableTitle)
    }

    func failTokenizeData(_ error: Error) {
        guard paymentResult != .cancel else {
            shouldInvalidateTokenizeData = true
            return
        }
        trackScreenErrorAnalytics()
        output?.presentErrorWithMessage(§Localized.Error.failTokenizeData)
    }

    func didPressSubmitButton(on module: ApplePayContractModuleInput) {
        output?.presentApplePay(paymentOption)
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
    func bankCardDataInputModule(
        _ module: BankCardDataInputModuleInput,
        didPressConfirmButton bankCardData: CardData
    ) {}
    func didLoginInWallet(_ response: YamoneyLoginResponse) {}
    func yamoneyAuthParameters(
        _ module: YamoneyAuthParametersModuleInput,
        loginWithReusableToken isReusableToken: Bool
    ) {}
    func failLoginInWallet(_ error: Error) {}
    func failResendSmsCode(_ error: Error) {}
    func sberbankModule(_ module: SberbankModuleInput, didPressConfirmButton phoneNumber: String) {}
    func didPressConfirmButton(on module: BankCardDataInputModuleInput, cvc: String) {}
    func didPressLogout() {}
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
