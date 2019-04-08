import struct YandexCheckoutPaymentsApi.Tokens
import enum YandexCheckoutPaymentsApi.PaymentMethodType

/// Input data for tokenization module.
public struct TokenizationModuleInputData {

    /// Client application key.
    let clientApplicationKey: String

    /// Name of shop.
    let shopName: String

    /// Purchase description.
    let purchaseDescription: String

    /// Gateway ID. Setup, is provided at check in Yandex Checkout.
    /// The cashier at the division of payment flows within a single account.
    let gatewayId: String?

    /// Amount of payment.
    let amount: Amount

    /// Tokenization settings.
    let tokenizationSettings: TokenizationSettings

    /// Test mode settings.
    let testModeSettings: TestModeSettings?

    /// Bank card scanning.
    let cardScanning: CardScanning?

    /// Apple Pay merchant ID.
    let applePayMerchantIdentifier: String?

    /// Return url for close 3ds.
    let returnUrl: String?

    /// Enable logging
    let isLoggingEnabled: Bool

    /// User phone number.
    /// Example: +X XXX XXX XX XX
    let userPhoneNumber: String?

    /// Settings to customize SDK interface.
    let customizationSettings: CustomizationSettings

    /// Creates instance of `TokenizationModuleInputData`.
    ///
    /// - Parameters:
    ///   - clientApplicationKey: Client application key.
    ///   - shopName: Name of shop.
    ///   - purchaseDescription: Purchase description.
    ///   - gatewayId: Gateway ID. Setup, is provided at check in Yandex Checkout.
    ///                The cashier at the division of payment flows within a single account.
    ///   - amount: Amount of payment.
    ///   - tokenizationSettings: Tokenization settings.
    ///   - testModeSettings: Test mode settings.
    ///   - cardScanning: Bank card scanning.
    ///   - applePayMerchantIdentifier: Apple Pay merchant ID.
    ///   - returnUrl: Return url for close 3ds.
    ///   - isLoggingEnabled: Enable logging.
    ///   - userPhoneNumber: User phone number.
    ///                      Example: +X XXX XXX XX XX
    ///   - customizationSettings: Settings to customize SDK interface.
    ///
    /// - Returns: Instance of `TokenizationModuleInputData`.
    public init(clientApplicationKey: String,
                shopName: String,
                purchaseDescription: String,
                amount: Amount,
                gatewayId: String? = nil,
                tokenizationSettings: TokenizationSettings = TokenizationSettings(),
                testModeSettings: TestModeSettings? = nil,
                cardScanning: CardScanning? = nil,
                applePayMerchantIdentifier: String? = nil,
                returnUrl: String? = nil,
                isLoggingEnabled: Bool = false,
                userPhoneNumber: String? = nil,
                customizationSettings: CustomizationSettings = CustomizationSettings()) {
        self.clientApplicationKey = makeBase64Encoded(clientApplicationKey + ":")
        self.shopName = shopName
        self.purchaseDescription = purchaseDescription
        self.amount = amount
        self.gatewayId = gatewayId
        self.tokenizationSettings = tokenizationSettings
        self.testModeSettings = testModeSettings
        self.cardScanning = cardScanning
        self.applePayMerchantIdentifier = applePayMerchantIdentifier
        self.returnUrl = returnUrl
        self.isLoggingEnabled = isLoggingEnabled
        self.userPhoneNumber = userPhoneNumber
        self.customizationSettings = customizationSettings
    }
}

/// Input for tokenization module.
///
/// In the process of running mSDK, allows you to run processes using the `TokenizationModuleInput` protocol methods.
public protocol TokenizationModuleInput: class {

    /// Start 3-D Secure process.
    ///
    /// - Parameters:
    ///   - requestUrl: URL string for request website.
    ///   - redirectUrl: URL string for website of the card issuing bank to authorize the transaction.
    @available(*, deprecated, message: "redirectUrl no longer needed, will be deleted in next version")
    func start3dsProcess(requestUrl: String, redirectUrl: String)

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
    func didFinish(on module: TokenizationModuleInput)

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
    func tokenizationModule(_ module: TokenizationModuleInput,
                            didTokenize token: Tokens,
                            paymentMethodType: PaymentMethodType)
}

private func makeBase64Encoded(_ string: String) -> String {
    guard let data = string.data(using: .utf8) else {
        return string
    }
    return data.base64EncodedString()
}
