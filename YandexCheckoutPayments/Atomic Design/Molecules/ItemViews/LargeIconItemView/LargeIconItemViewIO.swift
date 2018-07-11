import class UIKit.UIImage

/// LargeIconItemView input protocol
protocol LargeIconItemViewInput: class {

    /// Icon image
    var image: UIImage { get set }

    /// Action button title
    var actionButtonTitle: String { get set }

    /// Main textual content
    var title: String { get set }
}

/// LargeIconItemView output protocol
protocol LargeIconItemViewOutput: class {

    /// Tells output that action button is pressed
    ///
    /// - Parameter itemView: An item view object informing the output
    func didPressActionButton(in itemView: LargeIconItemViewInput)
}
