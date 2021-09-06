import UIKit

final class CardSettingsRouter: CardSettingsRouterInput {
    let transitionHandler: TransitionHandler
    init(transitionHandler: TransitionHandler) {
        self.transitionHandler = transitionHandler
    }

    func openInfo(title: String, details: String) {
        let data = SavePaymentMethodInfoModuleInputData(headerValue: title, bodyValue: details)
        let module = SavePaymentMethodInfoAssembly.makeModule(inputData: data)
        let container = UINavigationController(rootViewController: module)
        module.addCloseButtonIfNeeded(target: self, action: #selector(close))
        transitionHandler.present(container, animated: true, completion: nil)
    }

    @objc
    private func close() {
        transitionHandler.dismiss(animated: true, completion: nil)
    }
}
