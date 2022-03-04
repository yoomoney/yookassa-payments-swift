import Foundation
import UIKit

enum StorageKeys {
    static var configKey: String { "config".appendingLanguageCode() }
    static var assetsKey: String { "assets".appendingLanguageCode() }
}

class ConfigMediatorImpl: ConfigMediator {
    enum UpdateError: Error {
        case canceled
    }

    private let configService: ConfigService
    private let storage: KeyValueStoring

    init(service: ConfigService, storage: KeyValueStoring) {
        self.configService = service
        self.storage = storage
    }

    static var defaultConfig: Config {
        let name = "defaultConfig".appendingLanguageCode()
        guard
            let url = Bundle.framework.url(forResource: name, withExtension: "json")
        else { fatalError("URL for \(name).json not found ") }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(Config.self, from: data)
        } catch {
            fatalError("Could not load default config \(url); \nError: \(error)")
        }
    }

    private func write(config: Config) {
        storage.write(value: config, for: StorageKeys.configKey) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                PrintLogger.trace("Config written successfully")
            case .failure(let error):
                PrintLogger.debugWarn(
                    "Failed to write to storage",
                    info: ["error": error.localizedDescription]
                )
                PrintLogger.trace("Recovery attempt")
                self.storage.write(value: Config?.none, for: StorageKeys.configKey) { [weak self] _ in
                    self?.storage.write(value: config, for: StorageKeys.configKey) { recoveryResult in
                        switch recoveryResult {
                        case .success:
                            PrintLogger.trace("Config written successfully")
                        case .failure(let error):
                            PrintLogger.debugWarn(
                                "Failed to write to storage",
                                info: ["error": error.localizedDescription]
                            )
                        }
                    }
                }
            }
        }
    }

    private func write(assets: [URL: Data]) {
        storage.write(value: assets, for: StorageKeys.assetsKey) { result in
            switch result {
            case .success:
                PrintLogger.trace("Assets written successfully")
            case .failure(let error):
                PrintLogger.debugWarn(
                    "Failed to write to storage",
                    info: ["error": error.localizedDescription]
                )
            }
        }
    }

    private func update(token: String, completion: @escaping (Result<Config, Error>) -> Void) {
        configService.getConfig(token: token) { [weak self] result in
            guard let self = self else { return completion(.failure(UpdateError.canceled)) }
            switch result {
            case .success(let config):
                self.write(config: config)
                self.loadAssets(config: config) {
                    completion(.success(config))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func getConfig(token: String, completion: @escaping (Config) -> Void) {
        update(token: token) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                PrintLogger.debugWarn("Update config failed", info: ["error": error.localizedDescription])
                self.readStoredConfig(completion: completion)
            case .success(let config):
                completion(config)
            }
        }
    }

    private func readStoredConfig(completion: @escaping (Config) -> Void) {
        storage.readValue(for: StorageKeys.configKey) { [weak self] (result: Result<Config?, Error>) in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                PrintLogger.debugWarn("Read storage failed", info: ["error": error.localizedDescription])
                let config = ConfigMediatorImpl.defaultConfig
                self.storage.write(value: config, for: StorageKeys.configKey, completion: nil)
                completion(config)
            case .success(.none):
                PrintLogger.trace("Init default storage")
                let config = ConfigMediatorImpl.defaultConfig
                self.storage.write(value: config, for: StorageKeys.configKey, completion: nil)
                completion(config)
            case .success(let config?):
                completion(config)
            }
        }
    }

    func storedConfig() -> Config {
        do {
            if let config: Config = try storage.readValue(for: StorageKeys.configKey) {
                return config
            }
            PrintLogger.trace("stored config was nil")
            return ConfigMediatorImpl.defaultConfig
        } catch {
            PrintLogger.trace("read stored config failed", info: ["error": error.localizedDescription])
            return ConfigMediatorImpl.defaultConfig
        }
    }

    // MARK: - Asset managment

    func asset(for key: ConfigurableAssetKey) -> UIImage {
        let value: [String: Data]? = try? storage.readValue(for: StorageKeys.assetsKey)
        PrintLogger.trace(String(describing: value))
        let image = value?[key.localizedKey].flatMap { UIImage(data: $0) }
        return (image ?? defaultAsset(for: key))
    }

    func asset(for key: ConfigurableAssetKey, completion: @escaping (UIImage?) -> Void) {
        let value: [String: Data]? = try? storage.readValue(for: StorageKeys.assetsKey)
        PrintLogger.trace(String(describing: value))
        storage.readValue(for: StorageKeys.assetsKey) { (result: Result<[String: Data]?, Error>) in
            guard
                case .success(let assets) = result,
                let data = assets?[key.localizedKey],
                let image = UIImage(data: data)
            else { return completion(nil) }
            completion(image)
        }
    }

    private func defaultAsset(for key: ConfigurableAssetKey) -> UIImage {
        switch key {
        case .bankCard: return PaymentMethodResources.Image.unknown
        case .yoomoney: return PaymentMethodResources.Image.yooMoney
        case .sberbank: return PaymentMethodResources.Image.sberpay
        case .applePay: return PaymentMethodResources.Image.applePay
        case .logo: return UIImage.localizedImage("image.logo")
        }
    }

    private var loader: DataLoader?

    private func loadAssets(config: Config, completion: @escaping () -> Void) {
        guard loader == nil else {
            PrintLogger.debugWarn(
                "Attempt to start new assets loading while previous loading didn't finish",
                info: ["function": #function] )
            return
        }

        var urls: [String: URL] = [:]
        config.paymentMethods.forEach {
            if let key = ConfigurableAssetKey(rawValue: $0.kind.rawValue) {
                urls[key.localizedKey] = $0.iconUrl
            }
        }
        if let dark = URL(string: config.yooMoneyLogoUrlDark) {
            let key = (ConfigurableAssetKey.logo.rawValue + "_dark").appendingLanguageCode()
            urls[key] = dark
        }
        if let light = URL(string: config.yooMoneyLogoUrlLight) {
            let key = (ConfigurableAssetKey.logo.rawValue + "_light").appendingLanguageCode()
            urls[key] = light
        }

        let newLoader = DataLoader(urls: [URL](urls.values))
        newLoader.load { [weak self] result in
            guard let self = self else { return }
            self.loader = nil
            PrintLogger.trace("Assets loading finished", info: ["result": String(describing: result)])
            var toStore: [String: Data] = [:]
            result.forEach { (url: URL, value: Result<Data, Error>) in
                let keysToUpdate = urls.keys.filter { urls[$0] == url }
                PrintLogger.trace(
                    "storing",
                    info: [
                        "keysToUpdate": keysToUpdate.debugDescription,
                        "url": url.debugDescription,
                    ]
                )
                if case .success(let data) = value {
                    keysToUpdate.forEach {
                        toStore[$0] = data
                    }
                }
            }
            self.storage.write(value: toStore, for: StorageKeys.assetsKey) { _ in }
            completion()
        }
        loader = newLoader
    }
}

private extension ConfigurableAssetKey {
    var localizedKey: String {
        switch self {
        case .bankCard, .yoomoney, .sberbank, .applePay:
            return rawValue.appendingLanguageCode()
        case .logo:
            let style: String
            if #available(iOS 13.0, *) {
                switch UIScreen.main.traitCollection.userInterfaceStyle {
                case .dark: style = "dark"
                case .light: style = "light"
                default: style = "light"
                }
            } else {
                style = "light"
            }

            return [rawValue, style].joined(separator: "_").appendingLanguageCode()
        }
    }
}

private extension String {
    func appendingLanguageCode() -> String {
        guard
            let code = Locale.autoupdatingCurrent.languageCode,
            ["ru", "en"].contains(code)
        else { return self + "_" + "ru" }

        return self + "_" + code
    }
}
