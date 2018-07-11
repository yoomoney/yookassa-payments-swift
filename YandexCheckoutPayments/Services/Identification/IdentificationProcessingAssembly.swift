enum IdentificationProcessingAssembly {

    static func makeService() -> IdentificationProcessing {
        return IdentificationService(session: ApiSessionAssembly.makeApiSession())
    }
}
