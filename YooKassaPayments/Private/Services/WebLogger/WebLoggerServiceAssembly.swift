enum WebLoggerServiceAssembly {
    static func makeService(
        isLoggingEnabled: Bool
    ) -> WebLoggerService {
        return WebLoggerServiceImpl(
            isLoggingEnabled: isLoggingEnabled
        )
    }
}
