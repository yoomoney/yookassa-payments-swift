import Foundation

struct EmailValidator: Validator {

    // swiftlint:disable force_unwrapping
    private let internalValidator = RegexValidator(pattern: """
^[-a-z0-9!#$%&'*+/=?^_`{|}~]+(?:\\.[-a-z0-9!#$%&'*+/=?^_`{|}~]+)*@(?:[a-z0-9]([-a-z0-9]{0,61}[a-z0-9])?\\.)*
(?:aero|arpa|asia|biz|cat|com|coop|edu|gov|info|int|jobs|mil|mobi|museum|name|net|org|pro|tel|travel|[a-z][a-z])$
""")!
    // swiftlint:enable force_unwrapping

    func validate(text: String) -> Bool {
        return internalValidator.validate(text: text)
    }
}
