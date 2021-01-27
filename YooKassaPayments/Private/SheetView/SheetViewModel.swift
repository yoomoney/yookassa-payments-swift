import UIKit

struct SheetViewModel {
    let cornerRadius: CGFloat
    let gripSize: CGSize
    let gripColor: UIColor
    let pullBarBackgroundColor: UIColor
    let treatPullBarAsClear: Bool

    static var `default`: SheetViewModel {
        return SheetViewModel(
            cornerRadius: 12,
            gripSize: CGSize(width: 35, height: 4),
            gripColor: UIColor(white: 0.868, black: 0.1),
            pullBarBackgroundColor: .clear,
            treatPullBarAsClear: true
        )
    }
}
