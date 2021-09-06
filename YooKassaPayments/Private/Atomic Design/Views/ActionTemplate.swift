import UIKit

/// Action template
class ActionTemplate: UIControl {

    // MARK: - Configuring the Control’s Attributes

    /// A Boolean value indicating whether the control is in the selected state.
    override var isSelected: Bool {
        didSet {
            updateStyledState()
        }
    }

    /// A Boolean value indicating whether the control draws a highlight.
    override var isHighlighted: Bool {
        didSet {
            updateStyledState()
        }
    }

    /// A Boolean value indicating whether the control is enabled.
    override var isEnabled: Bool {
        didSet {
            updateStyledState()
        }
    }

    /// The main view to which you add your templates’s custom content.
    var contentView: UIView? {
        willSet {
            contentView?.removeFromSuperview()
        }
        didSet {
            guard let contentView = contentView else { return }
            addSubview(contentView)
            contentView.isUserInteractionEnabled = false
            contentView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                contentView.left.constraint(equalTo: leftMargin),
                contentView.right.constraint(equalTo: rightMargin),
                contentView.top.constraint(equalTo: topMargin),
                contentView.bottom.constraint(equalTo: bottomMargin),
            ])
            updateContent(for: styledState)
            accessibilityTraits = UIAccessibilityTraits.button
        }
    }

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    // MARK: - Setup view

    private func setupView() {
        layoutMargins = .zero
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()
        contentView?.applyStyles()
    }

    // MARK: - Configuring ActionTemplate Presentation

    private(set) var styledState: UIControl.State = .normal {
        didSet {
            guard oldValue != styledState else { return }
            updateContent(for: styledState)
        }
    }

    private var styles: [UInt: InternalStyle] = [:]

    /// Sets the style to use for the specified state.
    ///
    /// - Parameter style: The style to use for the specified state.
    ///             state: The state that uses the specified style.
    func setStyle(_ style: InternalStyle, for state: UIControl.State) {
        styles[state.rawValue] = style
        if styledState == state {
            updateContent(for: state)
        }
    }

    // MARK: - Managing the View

    private func updateStyledState() {
        switch (isEnabled, isHighlighted, isSelected) {
        case (true, true, false):
            styledState = .highlighted
        case (true, false, true):
            styledState = .selected
        case (false, _, false):
            styledState = .disabled
        default:
            styledState = .normal
        }
    }

    private func updateContent(for state: UIControl.State) {
        guard let style = styles[state.rawValue] else { return }
        let view = contentView ?? self
        _ = styles.mapValues(view.removeStyle)
        view.appendStyle(style)
    }
}
