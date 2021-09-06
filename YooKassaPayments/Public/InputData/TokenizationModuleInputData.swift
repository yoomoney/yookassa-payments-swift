/// Input data for tokenization flow.
public struct TokenizationModuleInputData {

    /// Client application key.
    let clientApplicationKey: String

    /// Name of shop.
    let shopName: String

    /// Purchase description.
    let purchaseDescription: String

    /// Gateway ID. Setup, is provided at check in YooKassa.
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

    /// Setting for saving payment method.
    let savePaymentMethod: SavePaymentMethod

    /// Money center authorization identifier.
    let moneyAuthClientId: String?

    /// Application scheme for returning after opening a deeplink.
    /// Example: myapplication://
    let applicationScheme: String?

    /// Unique customer identifier by which you exclusively identify the custormer.
    /// Can be represented by phone, email or any other id which uniquely identifies the customer.
    let customerId: String?

    /// Creates instance of `TokenizationModuleInputData`.
    ///
    /// - Parameters:
    ///   - clientApplicationKey: Client application key.
    ///   - shopName: Name of shop.
    ///   - purchaseDescription: Purchase description.
    ///   - gatewayId: Gateway ID. Setup, is provided at check in YooKassa.
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
    ///   - savePaymentMethod: Setting for saving payment method.
    ///   - moneyAuthClientId: Money center authorization identifier
    ///   - applicationScheme: Application scheme for returning after opening a deeplink.
    ///
    /// - Returns: Instance of `TokenizationModuleInputData`.
    public init(
        clientApplicationKey: String,
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
        customizationSettings: CustomizationSettings = CustomizationSettings(),
        savePaymentMethod: SavePaymentMethod,
        moneyAuthClientId: String? = nil,
        applicationScheme: String? = nil,
        customerId: String? = nil
    ) {
        self.clientApplicationKey = (clientApplicationKey + ":").base64Encoded()
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
        self.savePaymentMethod = savePaymentMethod
        self.moneyAuthClientId = moneyAuthClientId
        self.applicationScheme = applicationScheme
        self.customerId = customerId
    }
}

extension TokenizationModuleInputData {
    var boolFromSavePaymentMethod: Bool? {
        switch savePaymentMethod {
        case .on: return true
        case .off: return false
        case .userSelects: return nil
        }
    }
}
