/// Input for tokenization module.
///
/// In the process of running mSDK, allows you to run processes using the `TokenizationModuleInput` protocol methods.
public protocol TokenizationModuleInput: AnyObject {

    /// Start 3-D Secure process.
    ///
    /// - Parameters:
    ///   - requestUrl: URL string for request website.
    @available(*, deprecated, message: "Use startConfirmationProcess(confirmationUrl:paymentMethodType:) instead")
    func start3dsProcess(requestUrl: String)

    /// Start confirmation process
    ///
    /// - Parameters:
    ///   - requestUrl: Deeplink.
    ///   - paymentMethodType: Type of the source of funds for the payment.
    func startConfirmationProcess(
        confirmationUrl: String,
        paymentMethodType: PaymentMethodType
    )
}

/// Output for tokenization module.
public protocol TokenizationModuleOutput: AnyObject {

    /// Will be called when the user has not completed the payment and completed the work.
    ///
    /// - Parameters:
    ///   - module: Input for tokenization module.
    ///             In the process of running mSDK, allows you to run processes using the
    ///             `TokenizationModuleInput` protocol methods.
    ///   - error: `YooKassaPaymentsError` error.
    func didFinish(
        on module: TokenizationModuleInput,
        with error: YooKassaPaymentsError?
    )

    /// Will be called when the 3-D Secure process successfully passes.
    ///
    /// - Parameters:
    ///   - module: Input for tokenization module.
    ///             In the process of running mSDK, allows you to run processes using the
    ///             `TokenizationModuleInput` protocol methods.
    @available(*, deprecated, message: "Use didSuccessfullyConfirmation(paymentMethodType:) instead")
    func didSuccessfullyPassedCardSec(
        on module: TokenizationModuleInput
    )

    /// Will be called when the confirmation process successfully passes.
    ///
    /// - Parameters:
    ///   - paymentMethodType: Type of the source of funds for the payment.
    func didSuccessfullyConfirmation(
        paymentMethodType: PaymentMethodType
    )

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
