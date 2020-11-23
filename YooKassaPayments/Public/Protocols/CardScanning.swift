import class UIKit.UIViewController

/// Contains successfully scanned bank card fields.
public struct ScannedCardInfo {

    /// Card number field.
    public let number: String?

    /// Expiry month field.
    public let expiryMonth: String?

    /// Expiry year field.
    public let expiryYear: String?

    /// Creates instance of `ScannedCardInfo`.
    ///
    /// - Parameters:
    ///   - number: Card number field.
    ///   - expiryMonth: Expiry month field.
    ///   - expiryYear: Expiry year field.
    ///
    /// - Returns: Instance of `ScannedCardInfo`.
    public init(number: String?, expiryMonth: String?, expiryYear: String?) {
        self.number = number
        self.expiryMonth = expiryMonth
        self.expiryYear = expiryYear
    }
}

/// Delegate for `CardScanning`.
///
/// The Protocol method allows to transfer the final data of the Bank card for further work.
public protocol CardScanningDelegate: class {

    /// Should be called when card scanning finished.
    ///
    /// - Parameter cardInfo: Contains scanned fields if has any.
    func cardScannerDidFinish(_ cardInfo: ScannedCardInfo?)
}

/// Scan your Bank card.
///
/// The type implementing the `CardScanning' protocol has the ability to show the view controller to scan the card.
/// With the implementation of the properties `cardScanningViewController` should be initialized view controller,
/// which is able to obtain credit card information.
///
/// - Example:
/// - Notes: The example uses a view controller from CardIO.
/// var cardScanningViewController: UIViewController? {
///   return CardIOPaymentViewController(paymentDelegate: self)
/// }
///
/// After receiving the Bank card data, the `ScannedCardInfo` data model should be initialized.
/// Next, using the property `cardScanningDelegate`, calling `cardScannerDidFinish(_ cardInfo:)` pass the data.
public protocol CardScanning: class {

    /// View controller to scan a bank card.
    var cardScanningViewController: UIViewController? { get }

    /// Delegate for `CardScanning`.
    var cardScanningDelegate: CardScanningDelegate? { get set }
}

extension ScannedCardInfo {

    /// Date of expiry of the card.
    var expiryDate: String? {
        guard let expiryMonth = expiryMonth.flatMap({ Int($0) }),
              let expiryYear = expiryYear.flatMap({ Int($0) }),
              expiryMonth > 0 && expiryYear > 0 else { return nil }
        return [expiryMonth, expiryYear].map { String(format: "%02i", $0 % 100) }.joined()
    }
}
