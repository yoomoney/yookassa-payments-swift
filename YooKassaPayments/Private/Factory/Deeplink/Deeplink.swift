/// Model for open app with specific deeplink.
enum DeepLink {
    /// Открывает окончание авторизации в приложении YooMoney с криптограмой.
    /// - Example: `scheme://yoomoney/exchange?cryptogram=someCryptogram`
    case yooMoneyExchange(cryptogram: String)
}
