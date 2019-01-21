import FunctionalSwift
import UIKit

protocol ModalTemplateDelegate: class {
    func shouldPopNavigationItem()
}

class ModalTemplate: UIViewController {

    weak var delegate: ModalTemplateDelegate?

    lazy var navigationBar: UINavigationBar = {
        $0.setStyles(UINavigationBar.Styles.default)
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self
        if #available(iOS 11.0, *) {
            $0.prefersLargeTitles = true
        }
        return $0
    }(UINavigationBar())

    // MARK: - Managing the Navigation Bar

    func setNavigationItems(_ items: [UINavigationItem]?, animated: Bool) {
        navigationBar.setItems(items, animated: animated)
        navigationBar.setNeedsLayout()
    }

    func pushNavigationItem(_ navigationItem: UINavigationItem, animated: Bool) {
        navigationBar.pushItem(navigationItem, animated: animated)
    }

    func popNavigationItem(animated: Bool) {
        navigationBar.popItem(animated: animated)
    }

    private var navigationBarConstraint: NSLayoutConstraint?

    func setNavigationBarHidden(_ hidden: Bool, animated: Bool) {
        navigationBarConstraint?.isActive = false
        if hidden {
            navigationBarConstraint = navigationBar.bottom.constraint(equalTo: view.top)
            if #available(iOS 11.0, *) {
                navigationBarConstraint = topLayoutGuide.topAnchor.constraint(equalTo: navigationBar.bottomAnchor)
            } else {
                let statusBarHeight = UIApplication.shared.statusBarFrame.height
                navigationBarConstraint = navigationBar.bottom.constraint(equalTo: view.topMargin,
                                                                          constant: statusBarHeight)
            }
        } else {
            if #available(iOS 11.0, *) {
                navigationBarConstraint = topLayoutGuide.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor)
            } else {
                let statusBarHeight = UIApplication.shared.statusBarFrame.height
                navigationBarConstraint = navigationBar.top.constraint(equalTo: view.topMargin,
                                                                       constant: statusBarHeight)
            }
        }

        navigationBarConstraint?.isActive = true

        if animated {
            UIView.animate(withDuration: TimeInterval(UINavigationController.hideShowBarDuration),
                           animations: {
                               self.view.layoutIfNeeded()
                           })
        }
    }

    override func loadView() {
        view = UIView()
        view.setStyles(UIView.Styles.grayBackground)
        loadSubviews()
        loadConstraints()
    }

    private func loadSubviews() {
        view.addSubview(navigationBar)
    }

    private func loadConstraints() {
        if #available(iOS 11.0, *) {
            view.insetsLayoutMarginsFromSafeArea = false
        }

        var constraints = [
            view.leading.constraint(equalTo: navigationBar.leading),
            view.trailing.constraint(equalTo: navigationBar.trailing),
        ]

        if #available(iOS 11.0, *) {
            navigationBarConstraint = topLayoutGuide.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor)
        } else {
            let statusBarHeight = UIApplication.shared.statusBarFrame.height
            navigationBarConstraint = navigationBar.top.constraint(equalTo: view.topMargin, constant: statusBarHeight)
        }

        navigationBarConstraint.map { constraints.append($0) }

        NSLayoutConstraint.activate(constraints)
    }

    func setContentView(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.frame = self.view.bounds
        self.view.insertSubview(view, at: 0)

        let constraints = [
            self.view.leading.constraint(equalTo: view.leading),
            self.view.trailing.constraint(equalTo: view.trailing),
            self.navigationBar.bottom.constraint(equalTo: view.top),
            self.view.bottom.constraint(equalTo: view.bottom),
        ]

        NSLayoutConstraint.activate(constraints)
    }

    // MARK: - Configuring the View’s Layout Behavior

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if #available(iOS 11.0, *) {
            if additionalSafeAreaInsets.top != navigationBar.frame.height {
                additionalSafeAreaInsets.top = navigationBar.frame.height
            }
        }
    }
}

extension ModalTemplate: UINavigationBarDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }

    public func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        delegate?.shouldPopNavigationItem()
        return true
    }
}
