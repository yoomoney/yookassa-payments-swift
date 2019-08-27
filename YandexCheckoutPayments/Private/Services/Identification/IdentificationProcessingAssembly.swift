enum IdentificationProcessingAssembly {

    static func makeService(isLoggingEnabled: Bool) -> IdentificationProcessing {
        let session = ApiSessionAssembly.makeApiSession(isLoggingEnabled: isLoggingEnabled)
        return IdentificationService(session: session)
    }
}
