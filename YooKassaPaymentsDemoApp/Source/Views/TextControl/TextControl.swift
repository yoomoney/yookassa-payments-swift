/* The MIT License
 *
 * Copyright © 2022 NBCO YooMoney LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

/// The TextControlDelegate protocol defines a set of optional methods you can use
/// to receive editing-related messages for TextControl objects
@objc protocol TextControlDelegate {

    @objc optional func textControlDidBeginEditing(_ textControl: TextControl)

    @objc optional func textControlDidEndEditing(_ textControl: TextControl)

    @objc optional func textControl(_ textControl: TextControl,
                                    shouldChangeTextIn range: NSRange,
                                    replacementText text: String) -> Bool

    @objc optional func textControlDidChange(_ textControl: TextControl)

    @objc optional func didPressRightButton(on textControl: TextControl)
}

/// TextControl supports the display of text using custom style information and also supports text editing
final class TextControl: UIView {

    // MARK: - Elements of the control

    private(set) lazy var textView = UITextView()
    private(set) lazy var topHintLabel = UILabel()
    private(set) lazy var bottomHintLabel = UILabel()
    private(set) lazy var placeholderLabel = UILabel()
    private(set) lazy var lineView: LineView = LineView()

    private(set) lazy var rightButton: UIButton = {
        $0.addTarget(self, action: #selector(rightButtonAction), for: .touchUpInside)
        return $0
    }(UIButton())

    private(set) lazy var clearButton: UIButton = {
        $0.setStyles(UIButton.Styles.clear)
        $0.addTarget(self, action: #selector(clearAction), for: .touchUpInside)
        return $0
    }(UIButton())

    private(set) lazy var leftIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.setStyles(UIImageView.Styles.dynamicSize)
        return imageView
    }()

    // MARK: - Private helpers

    private lazy var layoutController = LayoutController()
    private lazy var layout: Layout = Layout(control: self)

    fileprivate var isActive: Bool = false {
        didSet {
            guard oldValue != isActive else { return }
            updateControlElements(animated: true)
        }
    }

    private var isAccessibilitySizeCategory: Bool {
        return UIApplication.shared.preferredContentSizeCategory.isAccessibilitySizeCategory
    }

    // MARK: - Data for states of the control

    private var bottomHintTexts: [State: String] = [:]
    private var bottomHintColors: [State: UIColor] = [:]
    private var lineStates: [State: LineView.State] = [:]

    // MARK: - Public properties

    /// The receiver’s delegate
    weak var delegate: TextControlDelegate?

    /// The text displayed by the control
    var text: String? {
        get {
            return textView.text
        }
        set {
            textView.text = newValue
            updateControlElements()
        }
    }

    /// The styled text displayed by the control
    var attributedText: NSAttributedString? {
        get {
            return textView.attributedText
        }
        set {
            textView.attributedText = newValue
            updateControlElements()
        }
    }

    /// The placeholder text displayed by the control
    var placeholder: String? {
        didSet {
            placeholderLabel.text = placeholder
            updatePlaceholder()
        }
    }

    /// The state of the control
    var state: State = .default {
        didSet {
            updateControlElements(animated: true)
        }
    }

    /// The top hin text displayed by the text control
    var topHint: String? {
        didSet {
            topHintLabel.text = topHint
        }
    }

    var leftIconMode: TextControl.LeftIconMode = .default {
        didSet {
            updateLeftIcon()
        }
    }

    /// Controls when the standard clear button appears in the control
    var clearMode: TextControl.ClearMode = .default {
        didSet {
            updateClearButton()
        }
    }

    /// Controls when the placeholder appears in the control
    var placeholderMode: TextControl.PlaceholderMode = .default {
        didSet {
            updatePlaceholder()
        }
    }

    /// Controls when the top hint appears in the control
    var topHintMode: TextControl.TopHintMode = .default {
        didSet {
            updateTopHint()
        }
    }

    /// Controls when the bottom hint appears in the control
    var bottomHintMode: TextControl.BottomHintMode = .default {
        didSet {
            updateBottomHint()
        }
    }

    /// Controls when the right button appears in the control
    var rightButtonMode: TextControl.RightButtonMode = .default {
        didSet {
            updateRightButton()
        }
    }

    /// Controls when the line view appears in the control
    var lineMode: TextControl.LineMode = .default {
        didSet {
            updateLine()
        }
    }

    /// A Boolean value indicating whether a text of the control has no characters
    var isEmpty: Bool {
        return text?.isEmpty ?? true
            && attributedText?.length ?? 0 == 0
    }

    /// Padding of the control
    var padding: UIEdgeInsets = .zero {
        didSet {
            layout.padding = padding
            layoutIfNeeded()
        }
    }

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    // MARK: - Deinitializer

    deinit {
        unsubscribeFromContentSizeCategoryDidChange()
    }

    // MARK: - Overridden methods

    override var isFirstResponder: Bool {
        return textView.isFirstResponder
    }

    override func resignFirstResponder() -> Bool {
        return textView.resignFirstResponder()
    }

    override func becomeFirstResponder() -> Bool {
        return textView.becomeFirstResponder()
    }

    // MARK: - Setup control

    private func setup() {
        addSubview(lineView)
        addSubview(textView)
        _ = layout
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction(_:))))
        textView.delegate = self

        subscribeToContentSizeCategoryDidChange()
    }

    // MARK: - Public methods

    // MARK: - Right button

    /// Show the right button
    func showRightButton() {
        layoutController.show(rightButton, in: self, with: layout.rightButtonConstraints)
    }

    /// Hide the right button
    func hideRightButton() {
        layoutController.hide(rightButton)
    }

    // MARK: - Line view

    /// The state of the line in the control
    var lineState: LineView.State {
        get {
            return lineView.state
        }
        set (state) {
            lineView.state = state
        }
    }

    /// Fill the line
    ///
    /// - Parameters:
    ///   - color: Color of the line
    ///   - height: Height of the line
    ///   - animated: Set this value to true to animate the transition
    func fillLine(with color: UIColor, height: CGFloat, animated: Bool = true) {
        lineView.fillLine(with: color, height: height, animated: animated)
    }

    /// Hide the line
    ///
    /// - Parameter animated: Set this value to true to animate the transition
    func hideLine(animated: Bool = true) {
        lineView.hideLine(animated: animated)
    }

    // MARK: - Top hint

    /// Show top hint
    ///
    /// - Parameters:
    ///     - animated: Set this value to true to animate the transition
    ///     - constraints: The constraints that will be activated after adding view
    func showTopHint(constraints: [NSLayoutConstraint], animated: Bool = true) {
        layoutController.show(topHintLabel,
                              in: self,
                              with: constraints,
                              animation: animated ? .up : nil)
    }

    /// Hide top hint
    func hideTopHint() {
        layoutController.hide(topHintLabel)
    }

    // MARK: - Bottom hint

    /// Show button hint
    ///
    /// - Parameter animated: Set this value to true to animate the transition
    func showBottomHint(animated: Bool = true) {
        layoutController.show(bottomHintLabel,
                       in: self,
                       with: layout.bottomHintConstraints,
                       animation: animated ? .down : nil)
    }

    /// Hide bottom hint
    func hideBottomHint() {
        layoutController.hide(bottomHintLabel)
    }

    /// Set text of the bottom hint for state of the control
    ///
    /// - Parameters:
    ///   - bottomHintText: Text of the bottom hint or nil if no text
    ///   - state: State of the control
    func set(bottomHintText text: String?, for state: State) {
        bottomHintTexts[state] = text
        updateBottomHint()
    }

    /// Set color of the bottom hint for state of the control
    ///
    /// - Parameters:
    ///   - color: Color
    ///   - state: State of the control
    func set(bottomHintColor color: UIColor, for state: State) {
        bottomHintColors[state] = color
        updateBottomHint()
    }

    /// Set line state with color and height of the line for state of the control
    ///
    /// - Parameters:
    ///   - lineState: Line state with color and height
    ///   - state: State of the control
    func set(lineState: LineView.State, for state: State) {
        lineStates[state] = lineState
        updateLine()
    }

    // MARK: - Clear button private methods

    fileprivate func updateClearButton() {
        switch clearMode {
        case .never:
            hideClearButton()
        case .whileEditing where isActive && isEmpty == false:
            showClearButton()
        default:
            hideClearButton()
        }
    }

    private func showClearButton() {
        layoutController.show(clearButton, in: self, with: layout.clearButtonConstraints)
    }

    private func hideClearButton() {
        layoutController.hide(clearButton)
    }

    // MARK: - Left icon private methods

    private func showLeftIcon(constraints: [NSLayoutConstraint]) {
        layoutController.show(leftIcon, in: self, with: constraints)
    }

    private func hideLeftIcon() {
        layoutController.hide(leftIcon)
    }

    private func updateLeftIcon() {
        switch leftIconMode {
        case .never:
            hideLeftIcon()

        case .always:
            let constraints: [NSLayoutConstraint]
            if isAccessibilitySizeCategory {
                constraints = layout.accessibilityLeftIconConstraints
            } else {
                constraints = layout.leftIconConstraints
            }
            showLeftIcon(constraints: constraints)
        }
    }

    // MARK: - Placeholder private methods

    private func showPlaceholder() {
        layoutController.show(placeholderLabel, in: self, with: layout.placeholderConstraints)
    }

    private func hidePlaceholder() {
        layoutController.hide(placeholderLabel)
    }

    private func updatePlaceholder() {
        switch placeholderMode {
        case .never:
            hidePlaceholder()
        case .whileNotActiveAndEmpty where isActive == false && isEmpty:
            showPlaceholder()
        default:
            hidePlaceholder()
        }
    }

    // MARK: - Top hint private methods

    private func updateTopHint(animated: Bool = false) {
        switch topHintMode {
        case .never:
            hideTopHint()
        case .whileActiveOrNotEmpty where isActive || (isEmpty == false):
            let constraints: [NSLayoutConstraint]
            if leftIcon.image == nil {
                constraints = layout.topHintConstraints
            } else if isAccessibilitySizeCategory {
                constraints = layout.accessibilityTopHintConstraintsWithLeftIcon
            } else {
                constraints = layout.topHintConstraintsWithLeftIcon
            }
            showTopHint(constraints: constraints, animated: animated)
        default:
            hideTopHint()
        }
    }

    // MARK: - Bottom hint private methods

    private func updateBottomHint(animated: Bool = false) {

        let (text, color): (String?, UIColor?)

        switch (bottomHintMode, state, isActive) {
        case (.whileActiveWithStateOrError, _, true),
             (.whileActiveWithStateOrError, .error, false),
             (.whileActiveOrError, .error, false):
            text = bottomHintTexts[state]
            color = bottomHintColors[state]
        case (.whileActiveOrError, _, true):
            text = bottomHintTexts[.normal]
            color = bottomHintColors[.normal]
        default:
            text = nil
            color = nil
        }

        (bottomHintLabel.text, bottomHintLabel.textColor) = (text, color)

        if bottomHintLabel.text?.isEmpty ?? true {
            hideBottomHint()
        } else {
            showBottomHint(animated: animated)
        }
    }

    // MARK: - Right button private methods

    fileprivate func updateRightButton() {
        switch rightButtonMode {
        case .never:
            hideRightButton()
        case .whileError where state.isError:
            showRightButton()
        case .whileEmpty where isEmpty:
            showRightButton()
        case .whileNotActiveAndError where isActive == false && state.isError:
            showRightButton()
        case .whileErrorAndNotActiveOrEmpty where state.isError && (isActive == false || isEmpty):
            showRightButton()
        default:
            hideRightButton()
        }
    }

    // MARK: - Line view private methods

    private func updateLine() {

        let lineState: LineView.State?

        switch (lineMode, state, isActive) {
        case (.whileActiveWithStateOrError, _, true),
             (.whileActiveWithStateOrError, .error, false),
             (.whileActiveOrError, .error, false):
            lineState = lineStates[state]
        case (.whileActiveOrError, _, true):
            lineState = lineStates[.normal]
        default:
            lineState = nil
        }

        self.lineState = lineState ?? . clear
    }

    // MARK: - Control elements updating

    /// Update all elements of the control
    fileprivate func updateControlElements(animated: Bool = false) {
        updatePlaceholder()
        updateButtons()
        updateTopHint(animated: animated)
        updateBottomHint(animated: animated)
        updateLine()
        updateLeftIcon()
    }

    /// Update buttons of the control
    fileprivate func updateButtons() {
        updateClearButton()
        updateRightButton()
    }

    // MARK: - Private actions

    @objc
    private func clearAction() {
        if textView(textView,
                    shouldChangeTextIn: NSRange(location: 0, length: text?.count ?? 0),
                    replacementText: "") {
            text = ""
            textViewDidChange(textView)
        }
    }

    @objc
    private func tapAction(_ gestureRecognizer: UITapGestureRecognizer) {
        guard gestureRecognizer.state == .recognized else { return }
        _ = becomeFirstResponder()
    }

    @objc
    private func rightButtonAction() {
        delegate?.didPressRightButton?(on: self)
    }

    // MARK: - Content Size Category changing

    func subscribeToContentSizeCategoryDidChange() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(contentSizeCategoryDidChange),
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)
    }

    func unsubscribeFromContentSizeCategoryDidChange() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIContentSizeCategory.didChangeNotification,
                                                  object: nil)
    }

    @objc
    private func contentSizeCategoryDidChange() {
        applyStyles()
        textView.applyStyles()
        bottomHintLabel.applyStyles()
        topHintLabel.applyStyles()
        placeholderLabel.applyStyles()
        hideTopHint()
        updateControlElements()
    }

    // MARK: - TintColor actions

    override func tintColorDidChange() {
        applyStyles()
    }
}

// MARK: - UITextViewDelegate
extension TextControl: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        isActive = true
        delegate?.textControlDidBeginEditing?(self)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        isActive = false
        delegate?.textControlDidEndEditing?(self)
    }

    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        return delegate?.textControl?(self, shouldChangeTextIn: range, replacementText: text) ?? true
    }

    func textViewDidChange(_ textView: UITextView) {
        updateButtons()
        delegate?.textControlDidChange?(self)
    }
}
