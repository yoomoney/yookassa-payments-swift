import Dispatch

protocol ContractStateHandler: class {

    var view: ContractViewInput? { get set }

    func showActivity()
    func hideActivity()

    func showPlaceholder(message: String)
    func hidePlaceholder()

    func failLoginInYandexMoney(_ error: Error)
    func failTokenizeData(_ error: Error)
    func failResendSmsCode(_ error: Error)
}

extension ContractStateHandler {

    func showActivity() {
        DispatchQueue.main.async { [weak self] in
            guard let view = self?.view else { return }
            view.showActivity()
        }
    }

    func hideActivity() {
        DispatchQueue.main.async { [weak self] in
            guard let view = self?.view else { return }
            view.hideActivity()
        }
    }

    func showPlaceholder(message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let view = self?.view else { return }
            let state: ContractPlaceholderState = .message(message)
            view.showPlaceholder(state: state)
        }
    }

    func hidePlaceholder() {
        DispatchQueue.main.async { [weak self] in
            guard let view = self?.view else { return }
            view.hidePlaceholder()
        }
    }
}
