import UIKit

protocol SheetContentViewDelegate: class {
    func preferredHeightChanged(
        oldHeight: CGFloat,
        newSize: CGFloat
    )
}
