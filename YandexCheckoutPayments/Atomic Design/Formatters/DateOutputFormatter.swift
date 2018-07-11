import Foundation

struct DateOutputFormatter: Formatter {

    func format(input: String) -> String? {
        guard let date = DateFactory.dateInputFormatter.date(from: input) else { return nil }
        return DateFactory.dateOutputFormatter.string(from: date)
    }
}
