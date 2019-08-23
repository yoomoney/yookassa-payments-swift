import When
import YandexCheckoutShowcaseApi

typealias TitleWithForm = (title: String, form: [ContainerElement])

protocol IdentificationProcessing {

    func fetchIdentificationForm(merchantToken: String,
                                 language: String?) -> Promise<TitleWithForm>

    func sendIdentificationRequest(merchantToken: String,
                                   passportToken: String,
                                   fields: [String: String]) -> Promise<PersonifyRequest>

    func fetchIdentificationStatus(merchantToken: String,
                                   passportToken: String,
                                   requestId: String) -> Promise<PersonifyRequest>
}
