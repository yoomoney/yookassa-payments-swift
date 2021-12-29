import Foundation
import YooKassaPaymentsApi
import YooKassaWalletApi
import YooMoneyCoreApi

final class HostProvider {

    // MARK: - Init data

    private let settingsStorage: KeyValueStoring
    private let configStorage: KeyValueStoring
    private let defaultConfig: Config

    // MARK: - Init

    init(settingStorage: KeyValueStoring, configStorage: KeyValueStoring, defaultConfig: Config) {
        self.settingsStorage = settingStorage
        self.configStorage = configStorage
        self.defaultConfig = defaultConfig
    }
}

// MARK: - YooMoneyCoreApi.HostProvider

extension HostProvider: YooMoneyCoreApi.HostProvider {
    func host(for key: String) throws -> String {
        let isDevHost = settingsStorage.getBool(for: Settings.Keys.devHost) ?? false
        let host: String
        let mediator = ConfigMediatorAssembly.make(isLoggingEnabled: false)

        if isDevHost,
           let devHost = try makeDevHost(key: key) {
            host = devHost
        } else {
            let config: Config = mediator.storedConfig()
            let string: String
            switch key {
            case YooKassaPaymentsApi.Constants.paymentsApiMethodsKey:
                string = config.yooMoneyApiEndpoint.absoluteString
            case YooKassaWalletApi.Constants.walletApiMethodsKey:
                string = config.yooMoneyPaymentAuthorizationApiEndpoint.absoluteString
            case GlobalConstants.Hosts.moneyAuth:
                if let auth = config.yooMoneyAuthApiEndpoint, !auth.isEmpty {
                    string = auth
                } else {
                    string = "https://yoomoney.ru"
                }
            case GlobalConstants.Hosts.config:
                string = "https://yookassa.ru"
            default:
                throw HostProviderError.unknownKey(key)
            }

            guard var components = URLComponents(string: string) else { throw HostProviderError.unknownKey(key) }
            components.path = ""

            guard let url = components.url else { throw HostProviderError.unknownKey(key) }
            host = url.absoluteString
        }

        return host
    }

    private func makeDevHost(
        key: String
    ) throws -> String? {
        guard let devHosts = HostProvider.hosts else {
            return nil
        }

        let config = ConfigMediatorAssembly.make(isLoggingEnabled: false).storedConfig()

        let host: String

        switch key {
        case YooKassaWalletApi.Constants.walletApiMethodsKey:
            host = config.yooMoneyPaymentAuthorizationApiEndpoint.absoluteString
        case YooKassaPaymentsApi.Constants.paymentsApiMethodsKey:
            host = config.yooMoneyApiEndpoint.absoluteString
        case GlobalConstants.Hosts.moneyAuth:
            if let auth = config.yooMoneyAuthApiEndpoint, !auth.isEmpty {
                host = auth
            } else {
                host = devHosts.moneyAuth
            }
        case GlobalConstants.Hosts.config:
            host = devHosts.config
        default:
            throw HostProviderError.unknownKey(key)
        }

        guard var components = URLComponents(string: host) else { throw HostProviderError.unknownKey(key) }
        components.path = ""

        guard let url = components.url else { throw HostProviderError.unknownKey(key) }
        return url.absoluteString
    }

    private static var hosts: HostsConfig? = {
        guard
            let url = Bundle.framework.url(forResource: "Hosts", withExtension: "plist"),
            let hosts = NSDictionary(contentsOf: url) as? [String: Any],
            let walletHost = hosts[Keys.wallet.rawValue] as? String,
            let paymentsHost = hosts[Keys.payments.rawValue] as? String,
            let moneyAuthHost = hosts[Keys.moneyAuth.rawValue] as? String,
            let config = hosts[Keys.config.rawValue] as? String
        else {
            assertionFailure("Couldn't load Hosts.plist from framework bundle")
            return nil
        }

        return HostsConfig(
            wallet: walletHost,
            payments: paymentsHost,
            moneyAuth: moneyAuthHost,
            config: config
        )
    }()

    private enum Keys: String {
        case wallet
        case payments
        case moneyAuth
        case config
    }
}
