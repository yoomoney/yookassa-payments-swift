import PassKit

enum ApplePayConstants {

    static var paymentNetworks: [PKPaymentNetwork] {
        var optional: [PKPaymentNetwork] = []
        if #available(iOS 14.5, *) {
            /// TODO: Simplify when CI ready
            if let mir = PKPaymentRequest.availableNetworks().first(where: { $0.rawValue == "Mir" }) {
                optional.append(mir)
            }
        }
        return optional + [
            .amex,
            .masterCard,
            .visa,
        ]
    }
}
