import struct YandexCheckoutPaymentsApi.Tokens
import enum YandexCheckoutPaymentsApi.PaymentMethodType

/// Input for tokenization module.
///
/// In the process of running mSDK, allows you to run processes using the `TokenizationModuleInput` protocol methods.
public protocol TokenizationModuleInput: class {

    /// Start 3-D Secure process.
    ///
    /// - Parameters:
    ///   - requestUrl: URL string for request website.
    func start3dsProcess(requestUrl: String)
}

/// Output for tokenization module.
public protocol TokenizationModuleOutput: class {

    /// Will be called when the user has not completed the payment and completed the work.
    ///
    /// - Parameters:
    ///   - module: Input for tokenization module.
    ///             In the process of running mSDK, allows you to run processes using the
    ///             `TokenizationModuleInput` protocol methods.
    ///   - error: `YandexCheckoutPaymentsError` error.
    func didFinish(on module: TokenizationModuleInput,
                   with error: YandexCheckoutPaymentsError?)

    /// Will be called when the 3-D Secure process successfully passes.
    ///
    /// - Parameters:
    ///   - module: Input for tokenization module.
    ///             In the process of running mSDK, allows you to run processes using the
    ///             `TokenizationModuleInput` protocol methods.
    func didSuccessfullyPassedCardSec(on module: TokenizationModuleInput)

    /// Will be called when the tokenization process successfully passes.
    ///
    /// - Parameters:
    ///   - module: Input for tokenization module.
    ///             In the process of running mSDK, allows you to run processes using the
    ///             `TokenizationModuleInput` protocol methods.
    ///   - token: Tokenization payments data.
    ///   - paymentMethodType: Type of the source of funds for the payment.
    func tokenizationModule(
        _ module: TokenizationModuleInput,
        didTokenize token: Tokens,
        paymentMethodType: PaymentMethodType
    )
}

/// Default implementation for `TokenizationModuleOutput`
public extension TokenizationModuleOutput {
    func didFinish(on module: TokenizationModuleInput,
                   with error: YandexCheckoutPaymentsError?) {}
    func didSuccessfullyPassedCardSec(on module: TokenizationModuleInput) {}
    func tokenizationModule(
        _ module: TokenizationModuleInput,
        didTokenize token: Tokens,
        paymentMethodType: PaymentMethodType
    ) {}
}
