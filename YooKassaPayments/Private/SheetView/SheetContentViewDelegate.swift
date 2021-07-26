import UIKit

protocol SheetContentViewDelegate: AnyObject {
    func preferredHeightChanged(
        oldHeight: CGFloat,
        newSize: CGFloat
    )
}
