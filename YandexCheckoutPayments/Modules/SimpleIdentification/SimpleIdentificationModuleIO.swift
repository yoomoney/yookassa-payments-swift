protocol SimpleIdentificationModuleInput: class {

}

protocol SimpleIdentificationModuleOutput: class {
    func identificationDidFinishSuccess()
    func identificationDidClose()
}

struct SimpleIdentificationInputData {
    let merchantToken: String
    let language: String?
    let isLoggingEnabled: Bool

    init(merchantToken: String,
         language: String? = nil,
         isLoggingEnabled: Bool) {
        self.merchantToken = merchantToken
        self.language = language
        self.isLoggingEnabled = isLoggingEnabled
    }
}
