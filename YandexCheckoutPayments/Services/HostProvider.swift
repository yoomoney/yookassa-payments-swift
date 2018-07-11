import YandexCheckoutPaymentsApi
import YandexCheckoutShowcaseApi
import YandexCheckoutWalletApi
import YandexMoneyCoreApi

final class HostProvider: YandexMoneyCoreApi.HostProvider {

    func host(for key: String) throws -> String {
        let host: String

        switch key {
        case YandexCheckoutPaymentsApi.Constants.paymentsApiMethodsKey:
            host = "//payment.yandex.net"
        case YandexCheckoutShowcaseApi.Constants.personifyApiMethodsKey:
            host = "//money.yandex.ru"
        case YandexCheckoutWalletApi.Constants.walletApiMethodsKey:
            host = "//money.yandex.ru"
        default:
            throw HostProviderError.unknownKey(key)
        }

        return host
    }
}
