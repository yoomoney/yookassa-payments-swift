import Foundation
import YandexCheckoutShowcaseApi

enum DateFactory {

    static let dateOutputFormatter: DateFormatter = {
        $0.dateFormat = "yyyy-MM-dd"
        return $0
    }(DateFormatter())

    static let monthOutputFormatter: DateFormatter = {
        $0.dateFormat = "yyyy-MM"
        return $0
    }(DateFormatter())

    static let dateInputFormatter: DateFormatter = {
        $0.dateFormat = "dd.MM.yyyy"
        return $0
    }(DateFormatter())

    static let monthInputFormatter: DateFormatter = {
        $0.dateFormat = "MM.yyyy"
        return $0
    }(DateFormatter())

    static let calendar = Calendar(identifier: .gregorian)

    static func makeDate(dateElement: DateElement) -> Date? {

        switch dateElement {
        case .date(let date):
            return dateOutputFormatter.date(from: date)

        case .month(let month):
            return monthOutputFormatter.date(from: month)

        case .now:
            return calendar.startOfDay(for: Date())

        case .featurePeriod(let element, let period):
            guard let start = makeDate(dateElement: element) else { return nil }
            let components = makeComponents(from: period, negative: false)
            return calendar.date(byAdding: components, to: start)

        case .pastPeriod(let period, let element):
            guard let end = makeDate(dateElement: element) else { return nil }
            let components = makeComponents(from: period, negative: true)
            return calendar.date(byAdding: components, to: end)
        }
    }

    private static func makeComponents(from period: String, negative: Bool) -> DateComponents {
        var components = DateComponents()

        var curIndex = period.index(after: period.startIndex)

        if let yearIndex = period.index(of: "Y"),
            let year = Int(period[curIndex..<yearIndex]) {
            components.year = negative ? -year : year
            curIndex = period.index(after: yearIndex)
        }

        if let monthIndex = period.index(of: "M"),
            let month = Int(period[curIndex..<monthIndex]) {
            components.month = negative ? -month : month
            curIndex = period.index(after: monthIndex)
        }

        if let dayIndex = period.index(of: "D"),
            let day = Int(period[curIndex..<dayIndex]) {
            components.day = negative ? -day : day
        }

        return components
    }
}
