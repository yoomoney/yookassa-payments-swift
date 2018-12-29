import Foundation

final class SettingsService {

    // MARK: - Private properties

    private let storage: KeyValueStoring

    // MARK: - Initialization/Deinitialization

    init(storage: KeyValueStoring) {
        self.storage = storage
    }

    func loadSettingsFromStorage() -> Settings? {
        if let isTestModeEnadled = storage.getBool(for: Constants.isTestModeEnadledKey),
           let isPaymentAuthorizationPassed = storage.getBool(for: Constants.isPaymentAuthorizationPassedKey),
           let isPaymentWithError = storage.getBool(for: Constants.isPaymentWithErrorKey) {

            let cardsCount = storage.getInt(for: Constants.cardsCountKey)

            let testSettings = TestSettings(isTestModeEnadled: isTestModeEnadled,
                                                  isPaymentAuthorizationPassed: isPaymentAuthorizationPassed,
                                                  isPaymentWithError: isPaymentWithError,
                                                  cardsCount: cardsCount)

            if let isYandexMoneyEnabled = storage.getBool(for: Constants.isYandexMoneyEnabledKey),
               let isBankCardEnabled = storage.getBool(for: Constants.isBankCardEnabledKey),
               let isApplePayEnabled = storage.getBool(for: Constants.isApplePayEnabledKey),
               let isSberbankEnabled = storage.getBool(for: Constants.isSberbankEnabledKey),
               let isShowingYandexLogoEnabled = storage.getBool(for: Constants.isShowingYandexLogoEnabledKey),
               let price = storage.getDecimal(for: Constants.priceKey) {

                return Settings(isYandexMoneyEnabled: isYandexMoneyEnabled,
                                      isBankCardEnabled: isBankCardEnabled,
                                      isApplePayEnabled: isApplePayEnabled,
                                      isSberbankEnabled: isSberbankEnabled,
                                      isShowingYandexLogoEnabled: isShowingYandexLogoEnabled,
                                      price: price,
                                      testModeSettings: testSettings)
            }
        }

        return nil
    }

    func saveSettingsToStorage(settings: Settings) {
        storage.setBool(settings.isYandexMoneyEnabled,
                        for: Constants.isYandexMoneyEnabledKey)
        storage.setBool(settings.isBankCardEnabled,
                        for: Constants.isBankCardEnabledKey)
        storage.setBool(settings.isApplePayEnabled,
                        for: Constants.isApplePayEnabledKey)
        storage.setBool(settings.isSberbankEnabled,
                        for: Constants.isSberbankEnabledKey)
        storage.setBool(settings.isShowingYandexLogoEnabled,
                        for: Constants.isShowingYandexLogoEnabledKey)
        storage.setDecimal(settings.price,
                           for: Constants.priceKey)

        storage.setBool(settings.testModeSettings.isTestModeEnadled,
                        for: Constants.isTestModeEnadledKey)
        storage.setBool(settings.testModeSettings.isPaymentAuthorizationPassed,
                        for: Constants.isPaymentAuthorizationPassedKey)
        storage.setBool(settings.testModeSettings.isPaymentWithError,
                        for: Constants.isPaymentWithErrorKey)
        storage.setInt(settings.testModeSettings.cardsCount,
                       for: Constants.cardsCountKey)
    }
}

private extension SettingsService {
    enum Constants {
        static let isYandexMoneyEnabledKey = "isYandexMoneyEnabled"
        static let isBankCardEnabledKey = "isBankCardEnabled"
        static let isApplePayEnabledKey = "isApplePayEnabled"
        static let isSberbankEnabledKey = "isSberbankEnabled"
        static let isShowingYandexLogoEnabledKey = "isShowingYandexLogoEnabled"
        static let priceKey = "price"

        static let isTestModeEnadledKey = "isTestModeEnadled"
        static let isPaymentAuthorizationPassedKey = "isPaymentAuthorizationPassed"
        static let isPaymentWithErrorKey = "isPaymentWithError"
        static let cardsCountKey = "cardsCount"
    }
}
