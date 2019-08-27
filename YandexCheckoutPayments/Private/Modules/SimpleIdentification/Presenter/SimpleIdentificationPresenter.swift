import Foundation
import YandexCheckoutShowcaseApi

final class SimpleIdentificationPresenter {

    // MARK: - VIPER properties
    weak var view: SimpleIdentificationViewInput?
    weak var moduleOutput: SimpleIdentificationModuleOutput?
    var interactor: SimpleIdentificationInteractorInput!

    // MARK: - Data

    private var submitItem: SubmitDisplayItem!
    private var initialItems: [ShowcaseDisplayItem] = []
    private var currentItems: [ShowcaseDisplayItem] = []
    private var values: [String: OutputValue] = [:]

    private var isFormValid: Bool {
        return values.values.filter { $0.isRequired && !$0.valid }.isEmpty
    }

    private func updateView() {
        currentItems.removeAll()
        for index in initialItems.indices {
            var item = initialItems[index]

            if let name = item.name {
                item.value = values[name]?.value
            }

            currentItems.append(item)
            if case .select(_, let currentOption) = item, let option = currentOption {
                currentItems.append(contentsOf: option.group)
            }
        }
        view?.setDisplayItems(currentItems)
    }
}

// MARK: - SimpleIdentificationViewOutput
extension SimpleIdentificationPresenter: SimpleIdentificationViewOutput {

    func submitDidPress() {
        guard isFormValid else {
            view?.showError(§Localized.invalidForm)
            return
        }

        var fields: [String: String] = [:]
        values.forEach { fields[$0.key] = $0.value.value }
        interactor.sendForm(fields: fields)
    }

    func closeDidPress() {
        moduleOutput?.identificationDidClose()
    }

    func viewDidLoad() {
        interactor.fetchForm()
    }

    func changedInputText(_ text: String, valid: Bool, at index: Int) {
        let item = currentItems[index]
        if let name = item.name {
            values[name]?.value = text
            values[name]?.valid = valid
        }

        let submitEnabled = isFormValid

        if submitItem.isEnabled != submitEnabled {
            submitItem.isEnabled = submitEnabled
            view?.setSubmitItem(submitItem)
        }
    }

    func selectOption(_ option: SelectOptionDisplayItem, at index: Int) {
        let item = currentItems[index]
        guard case .select(let select, let currentOption) = item else { return }

        currentOption?.group.compactMap { $0.name }.forEach { values[$0] = nil }
        option.group.forEach {
            guard let name = $0.name else { return }
            let value = OutputValue(value: $0.value ?? "", valid: false, isRequired: $0.isRequired)
            values[name] = value
        }

        if let index = initialItems.firstIndex(of: item) {
            initialItems[index] = .select(select, currentOption: option)
        }
        values[select.name]?.value = option.value

        updateView()
    }
}

// MARK: - SimpleIdentificationModuleInput
extension SimpleIdentificationPresenter: SimpleIdentificationModuleInput {

}

// MARK: - SimpleIdentificationInteractorOutput
extension SimpleIdentificationPresenter: SimpleIdentificationInteractorOutput {

    func didSendForm(_ result: PersonifyRequest) {
        DispatchQueue.main.async { [weak self] in
            switch result.status {
            case .failed:
                self?.view?.showError("Error")

            case .pending:
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self?.interactor.fetchStatus(requestId: result.requestId)
                }

            case .succeeded:
                self?.moduleOutput?.identificationDidFinishSuccess()
            }
        }
    }

    func didSendForm(_ error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.view?.showError(error.localizedDescription)
        }
    }

    func didFetchForm(_ error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.view?.showError(error.localizedDescription)
        }
    }

    func didFetchForm(_ form: TitleWithForm) {

        let tuple = ShowcaseDisplayItemFactory.makeDisplayItem(form: form.form)

        guard let submitItem = tuple.submit else {
            DispatchQueue.main.async { [weak self] in
                self?.view?.showError(§Localized.incompleteForm)
            }
            return
        }

        self.initialItems = tuple.fields
        self.submitItem = submitItem

        for item in initialItems {
            if let name = item.name {
                values[name] = OutputValue(value: item.value ?? "", valid: false, isRequired: item.isRequired)
            }
        }

        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self, let view = strongSelf.view else { return }

            view.setTitle(form.title)
            strongSelf.updateView()
            view.setSubmitItem(submitItem)
        }
    }
}

private extension SimpleIdentificationPresenter {
    enum Localized: String {
        case invalidForm = "SimpleIdentification.Error.invalidForm"
        case incompleteForm = "SimpleIdentification.Error.incompleteForm"
    }
}

fileprivate struct OutputValue {
    var value: String
    var valid: Bool
    var isRequired: Bool
}
