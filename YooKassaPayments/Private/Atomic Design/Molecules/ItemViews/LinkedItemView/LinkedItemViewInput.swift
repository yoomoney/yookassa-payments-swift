/// LinkedItemView input protocol
protocol LinkedItemViewInput: class {

    /// Textual content
    var attributedString: NSAttributedString { get set }
}

/// LinkedItemView output protocol
protocol LinkedItemViewOutput: class {

    /// Tells output that was tap on linked view
    ///
    /// - Parameter itemView: An item view object informing the output
    func didTapOnLinkedView(on itemView: LinkedItemViewInput)
}
