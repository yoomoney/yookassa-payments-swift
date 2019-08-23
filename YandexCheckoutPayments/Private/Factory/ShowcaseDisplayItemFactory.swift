import Foundation
import FunctionalSwift
import YandexCheckoutShowcaseApi

typealias ShowcaseDisplayItemFactoryResult = (fields: [ShowcaseDisplayItem], submit: SubmitDisplayItem?)

enum ShowcaseDisplayItemFactory {

    static func makeDisplayItem(form: [ContainerElement]) -> ShowcaseDisplayItemFactoryResult {
        let submit = makeSubmit(form: form)
        let fields = makeFields(form:) -<< form

        return (fields: fields, submit: submit)
    }

    private static func makeFields(form: ContainerElement) -> [ShowcaseDisplayItem] {
        return makeDisplayItem(element: form)
    }

    private static func makeDisplayItem(element: ContainerElement) -> [ShowcaseDisplayItem] {

        switch element {
        case .container(let container):
            return makeItem(container: container)

        case .control(let control):
            return makeItem(control: control)
        }
    }

    private static func makeItem(container: Form) -> [ShowcaseDisplayItem] {

        switch container {
        case let group as GroupContainer:
            return makeFields(form:) -<< group.items

        case let paragraphContainer as ParagraphContainer:
            return [makeTextItem(container: paragraphContainer)]

        default:
            return []
        }
    }

    private static func makeItem(control: Control) -> [ShowcaseDisplayItem] {

        switch control {
        case let textControl as YandexCheckoutShowcaseApi.TextControl:
            return [makeInputTextItem(control: textControl)]

        case let emailControl as EmailControl:
            return [makeInputTextItem(control: emailControl)]

        case let phoneControl as PhoneControl:
            return [makeInputTextItem(control: phoneControl)]

        case let selectConttol as SelectControl:
            return [makeSelectItem(control: selectConttol)]

        case let dateControl as DateControl:
            return [makeInputTextItem(control: dateControl)]

        case let monthControl as MonthControl:
            return [makeInputTextItem(control: monthControl)]

        default:
            return []
        }
    }

    private static func makeSubmit(form: [ContainerElement]) -> SubmitDisplayItem? {

        var submit: SubmitDisplayItem?
        for element in form {
            if case .control(let control) = element,
               let submitControl = control as? SubmitControl {
                submit = makeSubmitItem(control: submitControl).first
                break
            }
        }

        return submit
    }

    private static func makeInputTextItem(control: YandexCheckoutShowcaseApi.TextControl) -> ShowcaseDisplayItem {

        let keyboard: UIKeyboardType = control.keyboardType == .number ? .numberPad : .default

        let item = TextInputDisplayItem(title: control.label,
                                        value: control.value,
                                        hint: control.hint,
                                        isEnabled: !control.readonly,
                                        isRequired: control.required,
                                        errorText: control.alert,
                                        name: control.name,
                                        type: .text(pattern: control.pattern,
                                                    minLenght: control.minLength,
                                                    maxlength: control.maxLength),
                                        keyboardType: keyboard)
        return .input(item)
    }

    private static func makeInputTextItem(control: EmailControl) -> ShowcaseDisplayItem {

        let item = TextInputDisplayItem(title: control.label,
                                        value: control.value,
                                        hint: control.hint,
                                        isEnabled: !control.readonly,
                                        isRequired: control.required,
                                        errorText: control.alert,
                                        name: control.name,
                                        type: .email,
                                        keyboardType: .emailAddress)
        return .input(item)
    }

    private static func makeInputTextItem(control: PhoneControl) -> ShowcaseDisplayItem {

        let item = TextInputDisplayItem(title: control.label,
                                        value: nil,
                                        hint: control.hint,
                                        isEnabled: !control.readonly,
                                        isRequired: control.required,
                                        errorText: control.alert,
                                        name: control.name,
                                        type: .phone,
                                        keyboardType: .numberPad)
        return .input(item)
    }

    private static func makeInputTextItem(control: DateControl) -> ShowcaseDisplayItem {

        var min: Date?
        if let minDate = control.min {
            min = DateFactory.makeDate(dateElement: minDate)
        }

        var max: Date?
        if let maxDate = control.max {
            max = DateFactory.makeDate(dateElement: maxDate)
        }

        let item = TextInputDisplayItem(title: control.label,
                                        value: control.value,
                                        hint: control.hint,
                                        isEnabled: !control.readonly,
                                        isRequired: control.required,
                                        errorText: control.alert,
                                        name: control.name,
                                        type: .date(format: .date, min: min, max: max),
                                        keyboardType: .numberPad)
        return .input(item)
    }

    private static func makeInputTextItem(control: MonthControl) -> ShowcaseDisplayItem {

        var min: Date?
        if let minDate = control.min {
            min = DateFactory.makeDate(dateElement: minDate)
        }

        var max: Date?
        if let maxDate = control.max {
            max = DateFactory.makeDate(dateElement: maxDate)
        }

        let item = TextInputDisplayItem(title: control.label,
                                        value: control.value,
                                        hint: control.hint,
                                        isEnabled: !control.readonly,
                                        isRequired: control.required,
                                        errorText: control.alert,
                                        name: control.name,
                                        type: .date(format: .month, min: min, max: max),
                                        keyboardType: .numberPad)
        return .input(item)
    }

    private static func makeSubmitItem(control: SubmitControl) -> [SubmitDisplayItem] {

        let items: [SubmitDisplayItem]

        switch control.items.count {
        case 0:
            items = [
                SubmitDisplayItem(title: control.name, isEnabled: false),
            ]

        default:
            items = control.items.map {
                return SubmitDisplayItem(title: "\($0.label)\n\($0.amount) \($0.currency)", isEnabled: false)
            }
        }

        return items
    }

    private static func makeTextItem(container: ParagraphContainer) -> ShowcaseDisplayItem {

        let strings = container.items.map { element -> String in

            switch element {
            case .text(let text):
                return text

            case .hyperlink(let hyperlink):
                return hyperlink.label
            }
        }

        let text = strings.joined(separator: " ")
        return .text(TextDisplayItem(text: text))
    }

    private static func makeSelectItem(control: SelectControl) -> ShowcaseDisplayItem {

        let options = control.options.map { option -> SelectOptionDisplayItem in

            let group = makeFields(form:) -<< option.group
            return SelectOptionDisplayItem(value: option.value,
                                           label: option.label,
                                           group: group)
        }

        let item = SelectDisplayItem(title: control.label,
                                     value: control.value,
                                     hint: control.hint,
                                     errorText: control.alert,
                                     name: control.name,
                                     options: options)

        let currentOption = options.first { $0.value == control.value }

        return .select(item, currentOption: currentOption)
    }
}
