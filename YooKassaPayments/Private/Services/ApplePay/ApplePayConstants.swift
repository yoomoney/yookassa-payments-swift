import struct PassKit.PKPaymentNetwork

enum ApplePayConstants {

    static var paymentNetworks: [PKPaymentNetwork] {
        var optional: [PKPaymentNetwork] = []
        if #available(iOS 14.5, *) {
            optional.append(.mir)
        }
        return optional + [.amex, .masterCard, .visa,]
    }
}
