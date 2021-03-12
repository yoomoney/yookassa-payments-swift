import Foundation

struct TestSettings {
    var isTestModeEnadled = true
    var isPaymentAuthorizationPassed = false
    var isPaymentWithError = false
    var cardsCount: Int? = 2
    var processConfirmation: ProcessConfirmation?
}
