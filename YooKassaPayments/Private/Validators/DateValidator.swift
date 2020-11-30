import Foundation

struct DateValidator: Validator {

    let min: Date?
    let max: Date?
    let formatter: DateFormatter

    init(formatter: DateFormatter, min: Date?, max: Date?) {
        self.formatter = formatter
        self.max = max
        self.min = min
    }

    func validate(text: String) -> Bool {

        guard let date = formatter.date(from: text) else {
            return false
        }

        if let min = self.min, date < min {
            return false
        }

        if let max = self.max, date > max {
            return false
        }

        return true
    }
}
