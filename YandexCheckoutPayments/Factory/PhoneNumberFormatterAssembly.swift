enum PhoneNumberFormatterAssembly {
    static func makeFormatter() -> PhoneNumberFormatter {
        return PhoneNumberFormatter(countryIdentifyMode: .manual)
    }
}
