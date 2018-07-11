import class PassKit.PKPaymentAuthorizationViewController

// MARK: - Presentable

extension PKPaymentAuthorizationViewController: Presentable {

    var iPhonePresentationStyle: PresentationStyle {
        return .applePay
    }

    var iPadPresentationStyle: PresentationStyle {
        return .applePay
    }

    public var hasNavigationBar: Bool {
        return false
    }
}
