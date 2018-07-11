protocol SimpleIdentificationModuleInput: class {

}

protocol SimpleIdentificationModuleOutput: class {
    func identificationDidFinishSuccess()
    func identificationDidClose()
}

struct SimpleIdentificationInputData {
    let merchantToken: String
    let language: String?

    init(merchantToken: String, language: String? = nil) {
        self.merchantToken = merchantToken
        self.language = language
    }
}
