/// SwitchItemView input protocol
protocol SwitchItemViewInput: AnyObject {

    /// Textual content
    var title: String { get set }

    /// Switch state
    var state: Bool { get set }
}

/// SwitchItemView output protocol
protocol SwitchItemViewOutput: AnyObject {

    /// Tells output that switch state is changed
    ///
    /// - Parameter itemView: An item view object informing the output
    ///   - state: New switch state
    func switchItemView(_ itemView: SwitchItemViewInput,
                        didChangeState state: Bool)
}
