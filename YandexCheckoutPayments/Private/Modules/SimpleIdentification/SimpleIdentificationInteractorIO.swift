import YandexCheckoutShowcaseApi

protocol SimpleIdentificationInteractorInput: class {
    func fetchForm()
    func sendForm(fields: [String: String])
    func fetchStatus(requestId: String)
}

protocol SimpleIdentificationInteractorOutput: class {
    func didFetchForm(_ form: TitleWithForm)
    func didFetchForm(_ error: Error)

    func didSendForm(_ result: PersonifyRequest)
    func didSendForm(_ error: Error)
}
