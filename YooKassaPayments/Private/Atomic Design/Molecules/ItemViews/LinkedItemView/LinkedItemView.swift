import UIKit

final class LinkedItemView: UIView {

    // MARK: - Public accessors

    var attributedString: NSAttributedString {
        get {
            return linkedTextView.attributedText
        }
        set {
            linkedTextView.attributedText = newValue
        }
    }

    // MARK: - SwitchItemViewOutput

    weak var delegate: LinkedItemViewOutput?

    // MARK: - UI properties

    private(set) lazy var linkedTextView: LinkedTextView = {
        let view = LinkedTextView()
        view.setStyles(UIView.Styles.grayBackground,
                       UITextView.Styles.linked)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()

    // MARK: - Constraints

    private var activeConstraints: [NSLayoutConstraint] = []

    // MARK: - Creating a View Object, deinitializer.

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    deinit {
        unsubscribeFromNotifications()
    }

    // MARK: - Setup view
    private func setupView() {
        backgroundColor = .clear
        layoutMargins = UIEdgeInsets(top: Space.double,
                                     left: Space.double,
                                     bottom: Space.double,
                                     right: Space.double)
        subscribeOnNotifications()
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        [
            linkedTextView,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
    }

    private func setupConstraints() {
        NSLayoutConstraint.deactivate(activeConstraints)
        activeConstraints = [
            linkedTextView.leading.constraint(equalTo: leadingMargin),
            linkedTextView.top.constraint(equalTo: topMargin),
            linkedTextView.trailing.constraint(equalTo: trailingMargin),
            linkedTextView.bottom.constraint(equalTo: bottomMargin),
        ]
        NSLayoutConstraint.activate(activeConstraints)
    }

    // MARK: - Notifications

    private func subscribeOnNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contentSizeCategoryDidChange),
            name: UIContentSizeCategory.didChangeNotification,
            object: nil
        )
    }

    private func unsubscribeFromNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc
    private func contentSizeCategoryDidChange() {
        linkedTextView.applyStyles()
        setupConstraints()
    }

    // MARK: - TintColor actions

    override func tintColorDidChange() {
        linkedTextView.tintColor = tintColor
        applyStyles()
    }
}

// MARK: - SwitchItemViewInput

extension LinkedItemView: LinkedItemViewInput {}

// MARK: - ListItemView

extension LinkedItemView: ListItemView {
    var leftSeparatorInset: CGFloat {
        return linkedTextView.frame.minX
    }
}

// MARK: - UITextViewDelegate

extension LinkedItemView: UITextViewDelegate {
    func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange
    ) -> Bool {
        delegate?.didTapOnLinkedView(on: self)
        return false
    }
}
