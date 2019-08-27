import class UIKit.UIImage

/// IconButtonItemView input protocol
protocol IconButtonItemViewInput: class {

    /// Main textual content
    var title: String { get set }

    /// Icon image
    var image: UIImage? { get set }

    /// Button title
    var buttonTitle: String? { get set }
}

/// IconButtonItemView output protocol
protocol IconButtonItemViewOutput: class {

    /// Tells output that the button is pressed
    ///
    /// - Parameter itemView: An item view object informing the output
    func didPressButton(in itemView: IconButtonItemViewInput)
}
