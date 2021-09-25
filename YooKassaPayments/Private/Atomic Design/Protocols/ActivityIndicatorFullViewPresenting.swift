/*
 * The MIT License (MIT)
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

/// Presenting Activity indicator over full view
protocol ActivityIndicatorFullViewPresenting: ActivityIndicatorPresenting {

    /// UIView to present Activity indicator as subview.
    var activityContainerView: UIView { get }

    /// Show the full view activity indicator with style
    func showFullViewActivity(style: InternalStyle)

    /// Hide the full view activity indicator with style.
    func hideFullViewActivity()
}

// MARK: - UIViewController
extension ActivityIndicatorFullViewPresenting where Self: UIViewController {
    var activityContainerView: UIView {
        return view
    }

    func showFullViewActivity(style: InternalStyle) {
        guard addedActivityIndicatorView == nil else { return }
        let activityIndicatorView = ActivityIndicatorView()
        activityIndicatorView.setStyles(style)
        activityContainerView.addSubview(activityIndicatorView)
        setupConstraints(for: activityIndicatorView)
        activityIndicatorView.activity.startAnimating()
    }

    func hideFullViewActivity() {
        addedActivityIndicatorView?.removeFromSuperview()
    }

    func showActivity() {
        showFullViewActivity(style: ActivityIndicatorView.Styles.dark)
    }

    func hideActivity() {
        hideFullViewActivity()
    }

    private var addedActivityIndicatorView: UIView? {
        return activityContainerView.subviews.first { $0 is ActivityIndicatorView }
    }

    private func setupConstraints(for activityIndicatorView: UIView) {
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityContainerView.left.constraint(equalTo: activityIndicatorView.left),
            activityContainerView.right.constraint(equalTo: activityIndicatorView.right),
            activityContainerView.top.constraint(equalTo: activityIndicatorView.top),
            activityContainerView.bottom.constraint(equalTo: activityIndicatorView.bottom),
        ])
    }
}
