import Foundation

struct AnalyticsEventContext {
    let sdkVersion: String
    let initialAuthType: AnalyticsEvent.AuthType
    let isCustomerIdPresent: Bool
    let isWalletAuthPresent: Bool
    let usingCustomColor: Bool
    let yookassaIconShown: Bool
    let savePaymentMethod: SavePaymentMethod
}
