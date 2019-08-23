enum TextInputOutputFormatterFactory {

    static func makeOutputFormatter(_ item: TextInputDisplayItem) -> Formatter? {
        var result: Formatter?

        switch item.type {

        case .text(_, _, _):
            result = nil

        case .email:
            result = nil

        case .phone:
            result = PhoneNumberOutputFormatter()

        case .date(let format, _, _):
            switch format {
            case .date:
                result = DateOutputFormatter()
            case .month:
                result = MonthOutputFormatter()
            }
        }

        return result
    }
}
