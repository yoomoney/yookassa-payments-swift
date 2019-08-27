enum TextInputPresenterStyleFactory {

    static func makeInputStyle(_ item: TextInputDisplayItem) -> InputPresenterStyle? {
        var result: InputPresenterStyle?

        switch item.type {

        case .text(_, _, let maxlength):
            if let max = maxlength {
                result = LengthTextInputPresenterStyle(maxLength: max)
            } else {
                result = nil
            }

        case .email:
            result = nil

        case .phone:
            let phoneNumberFormatter = PhoneNumberFormatter(countryIdentifyMode: .manual)
            result = PhoneNumberStyle(phoneNumberFormatter: phoneNumberFormatter)

        case .date(let format, _, _):
            switch format {
            case .date:
                result = DateInputPresenterStyle()
            case .month:
                result = MonthInputPresenterStyle()
            }
        }

        return result
    }
}
