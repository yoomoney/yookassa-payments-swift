import FunctionalSwift
import When
import YandexCheckoutShowcaseApi
import YandexMoneyCoreApi

class IdentificationService {

    // MARK: - Initial parameters
    fileprivate let session: ApiSession

    // MARK: - Creating object
    init(session: ApiSession) {
        self.session = session
    }
}

// MARK: - IdentificationServiceInput

extension IdentificationService: IdentificationProcessing {

    func sendIdentificationRequest(merchantToken: String,
                                   passportToken: String,
                                   fields: [String: String]) -> Promise<PersonifyRequest> {

        let method = PersonifyRequest.PostMethod(passportToken: passportToken,
                                                 merchantToken: merchantToken,
                                                 fields: fields)

        let result = session.perform(apiMethod: method).responseApi()
        return result
    }

    func fetchIdentificationForm(merchantToken: String, language: String?) -> Promise<TitleWithForm> {

        let method = PersonifyForm.Method(merchantToken: merchantToken)

        let response = session.perform(apiMethod: method).responseApi()
        let form = getForms <^> response
        return form
    }

    func fetchIdentificationStatus(merchantToken: String,
                                   passportToken: String,
                                   requestId: String) -> Promise<PersonifyRequest> {

        let method = PersonifyRequest.GetMethod(passportToken: passportToken,
                                                merchantToken: merchantToken,
                                                requestId: requestId)

        let result = session.perform(apiMethod: method).responseApi()
        return result
    }

    // MARK: - Service logic
    private func getForms(_ model: PersonifyForm) -> TitleWithForm {
        return TitleWithForm(title: model.title, form: model.form)
    }
}
