import struct PassKit.PKPaymentNetwork

enum ApplePayConstants {
    static let paymentNetworks: [PKPaymentNetwork] = [
        .amex,
        .masterCard,
        .visa,
    ]
}
