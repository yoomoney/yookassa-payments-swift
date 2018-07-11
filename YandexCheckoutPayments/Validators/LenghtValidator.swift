import Foundation

struct LenghtValidator: Validator {

    let range: ClosedRange<Int>

    init(range: ClosedRange<Int>) {
        self.range = range
    }

    func validate(text: String) -> Bool {
        return range ~= text.count
    }
}
