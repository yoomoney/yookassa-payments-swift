/* The MIT License
 *
 * Copyright © 2020 NBCO YooMoney LLC
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

extension TextControl {

    class LayoutController {

        /// Show view
        ///
        /// - Parameters:
        ///   - view: View to show
        ///   - parent: Сontainer where the view will be added
        ///   - constraints: The constraints that will be activated after adding view
        ///   - animation: Animation type, `nil` - if animation not needed
        ///
        /// - note: If view has superview, then nothing will happen
        func show(_ view: UIView,
                  in parent: UIView,
                  with constraints: [NSLayoutConstraint],
                  animation: Animation.Show? = nil) {

            guard view.superview == nil else { return }

            parent.addSubview(view)
            NSLayoutConstraint.activate(constraints)
            animation?.perform(for: view)
        }

        /// Hide the view
        ///
        /// - Parameter view: View to hide
        func hide(_ view: UIView) {
            view.removeFromSuperview()
        }
    }
}

extension TextControl.LayoutController {

    enum Animation {
        enum Show {
            case up
            case down
        }
    }
}

extension TextControl.LayoutController.Animation.Show {

    func perform(for view: UIView) {
        guard let parent = view.superview else {
            return
        }

        let frame = view.frame
        prepare(frame: &view.frame)
        let cover = coverView(for: view, with: parent)
        view.alpha = 0

        UIView.animate(
            withDuration: settings.duration,
            delay: settings.delay,
            usingSpringWithDamping: settings.damping,
            initialSpringVelocity: settings.velocity,
            options: [],
            animations: {
                view.alpha = 1
                view.frame = frame
            },
            completion: { _ in
                cover.removeFromSuperview()
            })
    }
}

private extension TextControl.LayoutController.Animation.Show {

    func prepare(frame: inout CGRect) {
        switch self {
        case .up:
            frame.origin.y += frame.size.height
        case .down:
            frame.origin.y -= frame.size.height
        }
    }

    var settings: AnimationSettings {
        switch self {
        case .up:
            return Constants.Up.settings
        case .down:
            return Constants.Down.settings
        }
    }

    func coverView(for view: UIView, with parent: UIView) -> UIView {
        let cover = UIView(frame: view.frame)
        cover.backgroundColor = parent.backgroundColor
        parent.addSubview(cover)
        parent.sendSubviewToBack(cover)
        parent.sendSubviewToBack(view)
        return cover
    }
}

private struct AnimationSettings {
    let duration: TimeInterval
    let delay: TimeInterval
    let damping: CGFloat
    let velocity: CGFloat
}

private extension TextControl.LayoutController.Animation.Show {
    enum Constants {
        // swiftlint:disable:next type_name
        enum Up {
            static let settings = AnimationSettings(duration: 0.5, delay: 0.1, damping: 0.5, velocity: 1.2)
        }
        enum Down {
            static let settings = AnimationSettings(duration: 0.5, delay: 0.5, damping: 0.66, velocity: 1.2)
        }
    }
}
