/// Model for open app with specific deeplink.
enum DeepLink {
    /// Открывает экран завершения оплаты через SberPay.
    /// - Example: `scheme://invoicing/sberpay`
    case invoicingSberpay
}
