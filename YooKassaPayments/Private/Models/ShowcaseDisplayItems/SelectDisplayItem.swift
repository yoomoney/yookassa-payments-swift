struct SelectDisplayItem {
    let title: String?
    var value: String?
    let hint: String?
    let errorText: String?
    let name: String

    let options: [SelectOptionDisplayItem]
}

struct SelectOptionDisplayItem {
    let value: String
    let label: String
    let group: [ShowcaseDisplayItem]
}
