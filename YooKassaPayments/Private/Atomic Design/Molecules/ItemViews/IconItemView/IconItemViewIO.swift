import class UIKit.UIImage

/// IconItemView input protocol
protocol IconItemViewInput: class {

    /// Textual content
    var title: String { get set }

    /// Icon image
    var icon: UIImage { get set }
}
