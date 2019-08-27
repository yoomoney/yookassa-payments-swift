import Foundation

struct LengthTextInputPresenterStyle: InputPresenterStyle {

    let maxLength: Int

    init(maxLength: Int) {
        self.maxLength = maxLength
    }

    func removedFormatting(from string: String) -> String {
        return string
    }

    func appendedFormatting(to string: String) -> String {
        return string
    }

    var maximalLength: Int {
        return maxLength
    }
}
