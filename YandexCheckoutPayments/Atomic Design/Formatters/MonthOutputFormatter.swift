import Foundation

struct MonthOutputFormatter: Formatter {

    func format(input: String) -> String? {
        guard let date = DateFactory.monthInputFormatter.date(from: input) else { return nil }
        return DateFactory.monthOutputFormatter.string(from: date)
    }
}
