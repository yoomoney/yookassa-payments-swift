/// SwitchItemView input protocol
protocol LinkedSwitchItemViewInput: class {

    /// Textual content
    var attributedString: NSAttributedString { get set }

    /// Switch state
    var state: Bool { get set }
}

/// SwitchItemView output protocol
protocol LinkedSwitchItemViewOutput: class {

    /// Tells output that switch state is changed
    ///
    /// - Parameter itemView: An item view object informing the output
    ///   - state: New switch state
    func linkedSwitchItemView(_ itemView: LinkedSwitchItemViewInput,
                              didChangeState state: Bool)

    /// Tells output that was tap on linked view
    ///
    /// - Parameter itemView: An item view object informing the output
    func didTapOnLinkedView(on itemView: LinkedSwitchItemViewInput)
}
