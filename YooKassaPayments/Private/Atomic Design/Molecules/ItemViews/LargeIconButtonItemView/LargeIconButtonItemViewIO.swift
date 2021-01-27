import class UIKit.UIImage

/// LargeIconButtonItemView input protocol
protocol LargeIconButtonItemViewInput: class {

    /// Icon image
    var image: UIImage { get set }

    /// Title text
    var title: String { get set }

    /// Subtitle text
    var subtitle: String { get set }

    /// Right button title
    var rightButtonTitle: String { get set }
}

/// LargeIconButtonItemView output protocol

protocol LargeIconButtonItemViewOutput: class {

    /// Tells output that right button is pressd
    ///
    /// - Parameter itemView: An item view object informing the output
    func didPressRightButton(in itemView: LargeIconButtonItemViewInput)
}
