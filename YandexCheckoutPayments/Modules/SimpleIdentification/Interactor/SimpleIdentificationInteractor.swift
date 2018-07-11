import Foundation

enum SimpleIdentificationInteractorError: Error {
    case missingPassportToken
}

final class SimpleIdentificationInteractor {

    // MARK: - VIPER module
    weak var output: SimpleIdentificationInteractorOutput?

    let identificationService: IdentificationProcessing
    let authorizationService: AuthorizationProcessing

    // MARK: - Data properties
    let merchantToken: String
    let language: String?

    init(identificationService: IdentificationProcessing,
         authorizationService: AuthorizationProcessing,
         merchantToken: String,
         language: String?) {

        self.identificationService = identificationService
        self.authorizationService = authorizationService
        self.merchantToken = merchantToken
        self.language = language
    }
}

extension SimpleIdentificationInteractor: SimpleIdentificationInteractorInput {

    func sendForm(fields: [String: String]) {

        guard let passportToken = authorizationService.getYandexToken() else {
            output?.didSendForm(SimpleIdentificationInteractorError.missingPassportToken)
            return
        }

        let requestMethod = identificationService.sendIdentificationRequest(merchantToken: merchantToken,
                                                                            passportToken: passportToken,
                                                                            fields: fields)

        guard let output = output else { return }

        requestMethod.done(output.didSendForm)
        requestMethod.fail(output.didSendForm)
    }

    func fetchForm() {
        let formMethod = identificationService.fetchIdentificationForm(merchantToken: merchantToken,
                                                                       language: language)

        guard let output = output else { return }

        formMethod.done(output.didFetchForm)
        formMethod.fail(output.didFetchForm)
    }

    func fetchStatus(requestId: String) {

        guard let passportToken = authorizationService.getYandexToken() else {
            output?.didSendForm(SimpleIdentificationInteractorError.missingPassportToken)
            return
        }

        let statusMethod = identificationService.fetchIdentificationStatus(merchantToken: merchantToken,
                                                                           passportToken: passportToken,
                                                                           requestId: requestId)

        guard let output = output else { return }

        statusMethod.done(output.didSendForm)
        statusMethod.fail(output.didSendForm)
    }
}
