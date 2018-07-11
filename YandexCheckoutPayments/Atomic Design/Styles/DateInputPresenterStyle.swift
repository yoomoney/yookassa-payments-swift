import FunctionalSwift

struct DateInputPresenterStyle: InputPresenterStyle {

    func removedFormatting(from string: String) -> String {
        return string.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }

    func appendedFormatting(to string: String) -> String {
        let components = string.split(places: [2, 2, 4])
        return components.joined(separator: ".")
    }

    var maximalLength: Int {
        return 8
    }
}
