import UIKit

protocol ConfigMediator {
    func storedConfig() -> Config
    func getConfig(token: String, completion: @escaping (Config) -> Void)
    func asset(for key: ConfigurableAssetKey) -> UIImage
    func asset(for key: ConfigurableAssetKey, completion: @escaping (UIImage?) -> Void)
}

enum ConfigurableAssetKey: String {
    case bankCard = "bank_card"
    case yoomoney = "yoo_money"
    case sberbank = "sberbank"
    case applePay = "apple_pay"
    case logo = "logo"
}
