struct PhoneNumberOutputFormatter: Formatter {
    func format(input: String) -> String? {
        return input
            .components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()
    }
}
