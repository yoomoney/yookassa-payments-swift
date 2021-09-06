import UIKit

struct CardSettingsModuleInputData {
    enum Card {
        case yoomoney(name: String?)
        case card(name: String, id: String)
    }
    let cardLogo: UIImage
    let cardMask: String
    let infoText: String
    let card: Card

    let testModeSettings: TestModeSettings?
    let tokenizationSettings: TokenizationSettings
    let isLoggingEnabled: Bool
    let clientId: String
}

protocol CardSettingsModuleOutput: AnyObject {
    func cardSettingsModuleDidUnbindCard(mask: String)
    func cardSettingsModuleDidCancel()
}
