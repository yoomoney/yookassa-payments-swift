import Foundation

final class SectionDescriptor {

    var headerText: String?
    var footerText: String?

    var rows: [CellDescriptor]

    init(headerText: String? = nil, footerText: String? = nil, rows: [CellDescriptor]) {
        self.headerText = headerText
        self.footerText = footerText
        self.rows = rows
    }

}
