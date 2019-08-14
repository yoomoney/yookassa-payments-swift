/* The MIT License
 *
 * Copyright (c) 2007-2017 NBCO Yandex.Money LLC
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

import FunctionalSwift
import UIKit

/// Toast view with message and actions. You can use this view for presenting
/// message with error/success/info status to user. Default this view presenting
/// under navigation bar.
///
/// For additional user actions you must use `actions` property. `Action` instance
/// contains title of action (use as title of button) and closure with action.
@available(iOS 9.0, *)
class NotificationView: UIView {

    /// Struct with action.
    ///
    /// - SeeAlso: NotificationView documentation
    struct Action {
        let title: String
        let action: () -> Void

        init(title: String, action: @escaping () -> Void) {
            self.title = title
            self.action = action
        }
    }

    var message: String? {
        get {
            return label.text
        }
        set {
            label.text = newValue
            applyStyles()
        }
    }

    var actions: [Action] = [] {
        didSet {
            let buttons = actions.enumerated().map { self.makeButton(index: $0.0, action: $0.1) }
            buttonStackView.subviews.forEach { $0.removeFromSuperview() }
            buttonStackView.addArrangedSubview <^> buttons
            labelBottomSpaceConstraint.isActive = actions.isEmpty
            buttonsBottomSpaceConstraint.isActive = actions.isEmpty == false
        }
    }

    // MARK: - UI properties

    fileprivate let iconImageView = UIImageView()

    fileprivate let label = UILabel()

    fileprivate let buttonStackView = UIStackView()

    private var labelBottomSpaceConstraint: NSLayoutConstraint!
    private var buttonsBottomSpaceConstraint: NSLayoutConstraint!

    fileprivate var buttonStyles: [Style] = [] {
        didSet {
            _ = UIView.appendStyle <^> buttonStackView.subviews <*> buttonStyles
        }
    }

    // MARK: - Constraints

    private var activeConstraints: [NSLayoutConstraint] = []

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    // MARK: - Setup initial state

    private func setupView() {
        layoutMargins = UIEdgeInsets(top: Space.double,
                                     left: Space.double,
                                     bottom: Space.double,
                                     right: Space.double)
        subscribeOnNotifications()
        setupSubviews()
        setupConstraints()
    }

    private func setupSubviews() {
        let subviews: [UIView] = [
            iconImageView,
            label,
            buttonStackView,
        ]
        subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        addSubview <^> subviews
    }

    private func setupConstraints() {
        NSLayoutConstraint.deactivate(activeConstraints)
        if UIApplication.shared.preferredContentSizeCategory.isAccessibilitySizeCategory {
            buttonStackView.axis = .vertical
            activeConstraints = [
                iconImageView.top.constraint(equalTo: topMargin),
                iconImageView.leading.constraint(equalTo: leadingMargin),
                iconImageView.trailing.constraint(lessThanOrEqualTo: trailingMargin),

                label.top.constraint(equalTo: iconImageView.bottom,
                                     constant: Space.double),
                label.leading.constraint(equalTo: leadingMargin),
                label.trailing.constraint(equalTo: trailingMargin),

                buttonStackView.top.constraint(equalTo: label.bottom,
                                               constant: Space.double),
                buttonStackView.trailing.constraint(equalTo: trailingMargin),
                buttonStackView.leading.constraint(greaterThanOrEqualTo: leadingMargin),
            ]
        } else {
            buttonStackView.axis = .horizontal
            activeConstraints = [
                iconImageView.top.constraint(equalTo: topMargin),
                iconImageView.leading.constraint(equalTo: leadingMargin),
                iconImageView.bottom.constraint(lessThanOrEqualTo: bottomMargin),

                label.top.constraint(equalTo: topMargin),
                label.leading.constraint(equalTo: iconImageView.trailing,
                                         constant: Space.double),
                label.trailing.constraint(equalTo: trailingMargin),

                buttonStackView.top.constraint(equalTo: label.bottom,
                                               constant: Space.triple),
                buttonStackView.trailing.constraint(equalTo: trailingMargin),
                buttonStackView.leading.constraint(greaterThanOrEqualTo: leadingMargin),
            ]
        }

        labelBottomSpaceConstraint = bottomMargin.constraint(equalTo: label.bottom)
        buttonsBottomSpaceConstraint = bottomMargin.constraint(equalTo: buttonStackView.bottom)

        activeConstraints += [
            actions.isEmpty ? labelBottomSpaceConstraint : buttonsBottomSpaceConstraint,
            iconImageView.width.constraint(equalTo: iconImageView.height),
        ]

        NSLayoutConstraint.activate(activeConstraints)
    }

    // MARK: - Helper

    private func makeButton(index: Int, action: Action) -> UIButton {
        let button = UIButton(type: .custom)
        button.appendStyle <^> buttonStyles
        button.setStyledTitle(action.title, for: .normal)
        button.tag = index
        button.addTarget(self, action: #selector(actionButtonDidPressed(_:)), for: .touchUpInside)
        return button
    }

    // MARK: - Action

    @objc
    private func actionButtonDidPressed(_ sender: UIButton) {
        let index = sender.tag
        guard index < actions.count else { return }
        actions[index].action()
    }

    // MARK: - Notifications

    private func subscribeOnNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(contentSizeCategoryDidChange),
                                               name: UIContentSizeCategory.didChangeNotification,
                                               object: nil)
    }

    private func unsubscribeFromNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc
    private func contentSizeCategoryDidChange() {
        iconImageView.applyStyles()
        label.applyStyles()
        buttonStackView.arrangedSubviews.forEach {
            $0.applyStyles()
        }
        setupConstraints()
    }
}

@available(iOS 9.0, *)
extension NotificationView {

    // MARK: - Styles

    enum Styles {
        static let `default` = Style(name: "notificationViewDefault") { (view: NotificationView) in
            view.translatesAutoresizingMaskIntoConstraints = false
            view.label.setStyles(UILabel.DynamicStyle.body,
                                 UILabel.ColorStyle.inverse,
                                 UILabel.Styles.multiline)
            view.iconImageView.setStyles(UIImageView.Styles.dynamicSize)
            view.buttonStyles = [UIButton.DynamicStyle.inverseLink]
            view.buttonStackView.spacing = Space.double
            view.buttonStackView.alignment = .center
            view.buttonStackView.distribution = .equalCentering
        }

        /// Style for error notifications.
        ///
        /// `.redOrange` background, inverseLink buttons, body inverse multiline text.
        static let error = `default` +
            Style(name: "error") { (view: NotificationView) in
                view.backgroundColor = .redOrange
                view.iconImageView.image = UIImage.NotificationView.error
            }

        /// Style for success notifications.
        ///
        /// `.success` background, inverseLink buttons, body inverse multiline text.
        static let success = `default` +
            Style(name: "success") { (view: NotificationView) in
                view.backgroundColor = .success
                view.iconImageView.image = UIImage.NotificationView.success
            }

        /// Style for info notifications.
        ///
        /// `.codGray` background, inverseLink buttons, body inverse multiline text.
        static let info = `default` +
            Style(name: "info") { (view: NotificationView) in
                view.backgroundColor = .codGray
                view.iconImageView.image = UIImage.NotificationView.info
            }
    }
}
