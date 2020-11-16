import Foundation

enum ShowcaseDisplayItem {

    case input(TextInputDisplayItem)

    case text(TextDisplayItem)

    case select(SelectDisplayItem, currentOption: SelectOptionDisplayItem?)
}

extension ShowcaseDisplayItem {

    var value: String? {
        get {
            switch self {
            case .input(let item):
                return item.value
            case .text(_):
                return nil
            case .select(let item, _):
                return item.value
            }
        }
        set {
            switch self {
            case .input(var item):
                item.value = newValue
                self = .input(item)
            case .text(_):
                break
            case .select(var item, let option):
                item.value = newValue
                self = .select(item, currentOption: option)
            }
        }
    }

    var name: String? {
        switch self {
        case .input(let item):
            return item.name
        case .text(_):
            return nil
        case .select(let item, _):
            return item.name
        }
    }

    var isRequired: Bool {
        switch self {
        case .input(let item):
            return item.isRequired
        case .text(_),
             .select(_, _):
            return false
        }
    }
}

extension ShowcaseDisplayItem: Equatable {

    static func == (lhs: ShowcaseDisplayItem, rhs: ShowcaseDisplayItem) -> Bool {

        switch (lhs, rhs) {
        case let (.input(l), .input(r)): return l.name == r.name
        case let (.text(l), .text(r)): return l.text == r.text
        case let (.select(l, _), .select(r, _)): return l.name == r.name
        case (.input, _),
             (.text, _),
             (.select, _):
            return false
        }
    }
}
