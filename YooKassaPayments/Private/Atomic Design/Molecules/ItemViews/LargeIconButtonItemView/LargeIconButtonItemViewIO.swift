import class UIKit.UIImage

/// LargeIconButtonItemView input protocol
protocol LargeIconButtonItemViewInput: AnyObject {

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

protocol LargeIconButtonItemViewOutput: AnyObject {

    /// Tells output that right button is pressd
    ///
    /// - Parameter itemView: An item view object informing the output
    func didPressRightButton(in itemView: LargeIconButtonItemViewInput)
}
