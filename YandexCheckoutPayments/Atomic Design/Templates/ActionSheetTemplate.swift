import UIKit

protocol ActionSheetTemplateDelegate: class {
    func actionSheetTemplateDidFinish(_ template: ActionSheetTemplate)
}

class ActionSheetTemplate: UIViewController {

    weak var delegate: ActionSheetTemplateDelegate?

    lazy var dummyView: UIView = {
        $0.setStyles(UIView.Styles.grayBackground)
        $0.layer.mask = self.maskLayer
        $0.layer.masksToBounds = true
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layoutMargins = .zero
        return $0
    }(UIView())

    // MARK: - Configuring the View Rotation Settings

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        let orientation: UIInterfaceOrientationMask
        switch (traitCollection.userInterfaceIdiom, traitCollection.horizontalSizeClass) {
        case (.phone, .compact):
            orientation = .portrait
        default:
            orientation = .all
        }
        return orientation
    }

    // MARK: - Layer properties

    private let maskLayer = CAShapeLayer()

    // MARK: - Constraints properties

    fileprivate lazy var dummyViewLeadingConstraint: NSLayoutConstraint = {
        $0.priority = .defaultHigh
        return $0
    }(self.dummyView.leading.constraint(equalTo: self.view.leading))

    fileprivate lazy var dummyViewHeightConstraint: NSLayoutConstraint =
        self.dummyView.height.constraint(lessThanOrEqualTo: self.view.height,
                                         multiplier: Constants.maximumHeightMultiplier)

    private var dummyViewBottomConstraint: NSLayoutConstraint?

    // MARK: - Gesture recognizers

    fileprivate lazy var viewTapGestureRecognizer: UITapGestureRecognizer = {
        $0.delegate = self
        return $0
    }(UITapGestureRecognizer(target: self, action: #selector(viewTapRecognizerHandle(_:))))

    // MARK: - Managing the View

    override func loadView() {
        view = UIView()
        view.addGestureRecognizer(viewTapGestureRecognizer)
        loadSubviews()
        loadConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startKeyboardObserving()
    }

    override func viewWillDisappear(_ animated: Bool) {
        view.endEditing(true)
        stopKeyboardObserving()
        super.viewWillDisappear(animated)
    }

    private func loadSubviews() {
        view.addSubview(dummyView)
    }

    private func loadConstraints() {

        let bottomConstraint = dummyView.bottom.constraint(equalTo: view.bottom)
        bottomConstraint.priority = .highest

        let constraints = [
            bottomConstraint,
            dummyViewHeightConstraint,
            dummyViewLeadingConstraint,
            dummyView.width.constraint(equalTo: self.view.width),
            dummyView.top.constraint(greaterThanOrEqualTo: view.topMargin),
            dummyView.leading.constraint(greaterThanOrEqualTo: view.leading),
            dummyView.centerX.constraint(equalTo: view.centerX),
            dummyView.width.constraint(lessThanOrEqualToConstant: Constants.maximumWidth),
        ]

        NSLayoutConstraint.activate(constraints)
    }

    // MARK: - Configuring the View’s Layout Behavior

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        fixRoundCorners()
    }

    private func fixRoundCorners() {
        let size = CGSize(width: dummyView.bounds.width, height: view.bounds.height)
        let layerFrame = CGRect(origin: .zero, size: size)
        maskLayer.frame = layerFrame
        let bezierPath = UIBezierPath(roundedRect: layerFrame,
                                      byRoundingCorners: [.topLeft, .topRight],
                                      cornerRadii: CGSize(width: 8, height: 8))
        maskLayer.path = bezierPath.cgPath
    }

    // MARK: - Actions

    @objc
    func viewTapRecognizerHandle(_ gestureRecognizer: UITapGestureRecognizer) {
        guard gestureRecognizer.state == .recognized else { return }
        delegate?.actionSheetTemplateDidFinish(self)
    }
}

// MARK: - KeyboardObserver

extension ActionSheetTemplate: KeyboardObserver {
    func keyboardWillShow(with keyboardInfo: KeyboardNotificationInfo) {
        let viewFrame = view.convert(view.bounds, to: nil)
        guard viewFrame.isInfinite == false || viewFrame.isNull == false else { return }
        let intersection = viewFrame.intersection(keyboardInfo.endKeyboardFrame).height

        let bottomConstraint = dummyView.bottom.constraint(lessThanOrEqualTo: view.bottomMargin,
                                                           constant: -intersection)
        dummyViewBottomConstraint = bottomConstraint
        bottomConstraint.isActive = true

        let animation = {
            self.view.layoutIfNeeded()
        }

        if let duration = keyboardInfo.animationDuration,
           let animationCurve = keyboardInfo.animationCurve {

            let options = UIView.AnimationOptions(rawValue: UInt(animationCurve.rawValue))

            UIView.animate(withDuration: duration,
                           delay: 0,
                           options: options,
                           animations: animation)
        } else {
            animation()
        }
    }

    func keyboardWillHide(with keyboardInfo: KeyboardNotificationInfo) {
        dummyViewBottomConstraint?.isActive = false

        let animation = {
            self.view.layoutIfNeeded()
        }

        if let duration = keyboardInfo.animationDuration,
           let animationCurve = keyboardInfo.animationCurve {

            let options = UIView.AnimationOptions(rawValue: UInt(animationCurve.rawValue))

            UIView.animate(withDuration: duration,
                           delay: 0,
                           options: options,
                           animations: animation)
        } else {
            animation()
        }
    }

    func keyboardDidShow(with keyboardInfo: KeyboardNotificationInfo) {}

    func keyboardDidHide(with keyboardInfo: KeyboardNotificationInfo) {}

    func keyboardDidUpdateFrame(_ keyboardFrame: CGRect) {}
}

// MARK: - UIGestureRecognizerDelegate

extension ActionSheetTemplate: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard gestureRecognizer === viewTapGestureRecognizer else { return true }
        return touch.view?.isDescendant(of: dummyView) == false
    }
}

// MARK: - Constants

private extension ActionSheetTemplate {
    enum Constants {
        static let maximumWidth: CGFloat = 414
        static let maximumHeightMultiplier: CGFloat = 0.8
    }
}
