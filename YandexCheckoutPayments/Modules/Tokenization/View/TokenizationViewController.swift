import class PassKit.PKPaymentAuthorizationViewController
import FunctionalSwift
import UIKit

protocol Presentable {
    var iPhonePresentationStyle: PresentationStyle { get }
    var iPadPresentationStyle: PresentationStyle { get }
    var hasNavigationBar: Bool { get }
}

enum PresentationStyle {
    case actionSheet
    case pageSheet
    case modal
    case applePay
}

private let timeInterval = TimeInterval(UINavigationController.hideShowBarDuration)

class TokenizationViewController: UIViewController {

    // MARK: - VIPER module properties

    var output: (TokenizationViewOutput & TokenizationModuleInput)!

    // MARK: - Container properties

    var modules: [UIViewController] = []

    private weak var actionSheetTemplate: ActionSheetTemplate?
    private weak var modalTemplate: ModalTemplate?
    private weak var pageSheetTemplate: PageSheetTemplate?

    private var containerConstraints: [NSLayoutConstraint] = []

    // MARK: - Configuring the View Rotation Settings

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {

        let result: UIInterfaceOrientationMask

        if UIDevice.current.isIphonePlus {
            result = .allButUpsideDown
        } else if case .pad = UIDevice.current.userInterfaceIdiom {
            result = .all
        } else {
            result = .portrait
        }

        return result
    }

    // MARK: - Managing the View

    override func viewDidLoad() {
        super.viewDidLoad()
        output.setupView()

        if UIDevice.current.isIphonePlus == false {
            // https://stackoverflow.com/a/26358192/6108456
            // The only option of forced transfer to portrait mode.
            let value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        }
    }

    // MARK: - Responding to a Change in the Interface Environment

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        func getCurrentStyle() -> PresentationStyle {
            let style: PresentationStyle
            if actionSheetTemplate != nil {
                style = .actionSheet
            } else if modalTemplate != nil {
                style = .modal
            } else if pageSheetTemplate != nil {
                style = .pageSheet
            } else {
                style = .modal
            }

            return style
        }

        let style = getCurrentStyle()

        if let vc = modules.last,
           style != getStyle(vc) {
            if let actionSheet = actionSheetTemplate {
                hide(actionSheet: actionSheet)
            } else if let modal = modalTemplate {
                hide(modal: modal)
            } else if let pageSheet = pageSheetTemplate {
                hide(pageSheet: pageSheet)
            }

            switch getStyle(vc) {
            case .actionSheet:
                showActionSheet(vc, sender: self)
            case .pageSheet:
                showPageSheet(vc, sender: self)
            case .modal:
                showModal(vc, sender: self)
            case .applePay:
                break
            }
        }
    }

    // MARK: - Presenting View Controllers

    override func show(_ vc: UIViewController, sender: Any?) {
        push(vc, sender: sender)
    }

    // swiftlint:disable cyclomatic_complexity

    func push(_ viewController: UIViewController, sender: Any?) {
        let style = getStyle(viewController)

        if let previous = modules.last,
           let actionSheet = actionSheetTemplate,
           case .actionSheet = style {
            pushActionSheet(actionSheet, previous: previous, next: viewController, sender: sender)
        } else if let previous = modules.last,
                  let pageSheet = pageSheetTemplate,
                  case .pageSheet = style {
            pushPageSheet(pageSheet, previous: previous, next: viewController, sender: sender)
        } else if let previous = modules.last,
                  let modal = modalTemplate,
                  case .modal = style {
            pushModal(modal, previous: previous, next: viewController, sender: sender)
        } else if modules.last != nil,
                  let actionSheet = actionSheetTemplate,
                  case .modal = style {
            hideAnimated(actionSheet: actionSheet) {
                self.presentModalAnimated(viewController)
            }
        } else if modules.last != nil,
                  let modalTemplate = modalTemplate,
                  case .actionSheet = style {
            hideAnimated(modalTemplate: modalTemplate) {
                self.presentActionSheetAnimated(viewController)
            }
        } else if modules.last != nil,
                  let actionSheet = actionSheetTemplate,
                  case .applePay = style {
            // From ActionSheet to ApplePay
            hideAnimated(actionSheet: actionSheet) {
                self.showApplePay(viewController)
            }
        } else if modules.last != nil,
                  let pageSheet = pageSheetTemplate,
                  case .applePay = style {
            // From PageSheet to ApplePay
            hideAnimated(pageSheet: pageSheet) {
                self.showApplePay(viewController)
            }
        } else if modules.last is PKPaymentAuthorizationViewController,
                  case .actionSheet = style {
            // From ApplePay to ActionSheet
            dismiss(animated: true) {
                self.presentActionSheetAnimated(viewController)
            }
        } else if modules.last is PKPaymentAuthorizationViewController,
                  case .pageSheet = style {
            // From ApplePay to PageSheet
            dismiss(animated: true) {
                self.presentPageSheetAnimated(viewController)
            }
        } else if modules.last is PKPaymentAuthorizationViewController,
                  case .modal = style {
            // From ApplePay to Modal
            dismiss(animated: true) {
                self.presentModalAnimated(viewController)
            }
        } else {
            // First present. Animation doesn't needed
            switch style {
            case .actionSheet:
                showActionSheet(viewController, sender: sender)
            case .modal:
                showModal(viewController, sender: sender)
            case .pageSheet:
                showPageSheet(viewController, sender: sender)
            case .applePay:
                showApplePay(viewController)
            }
        }
    }

    func popViewController(animated: Bool) {
        guard modules.count > 2 else { return }

        let currentViewController = modules[modules.count - 1]
        let previousViewController = modules[modules.count - 2]
        let style = getStyle(previousViewController)

        if let modalTemplate = modalTemplate,
           case .modal = style {
            popModal(modalTemplate,
                     current: currentViewController,
                     previous: previousViewController,
                     sender: nil)
        } else if let pageSheetTemplate = pageSheetTemplate,
                  case .pageSheet = style {
            popPageSheet(pageSheetTemplate,
                         current: currentViewController,
                         previous: previousViewController,
                         sender: nil)
        }
    }

    // swiftlint:enable cyclomatic_complexity

    func showApplePay(_ vc: UIViewController) {
        appendIfNeeded(vc)
        present(vc, animated: true)
    }

    // MARK: - Get presentation style

    func getStyle(_ vc: UIViewController) -> PresentationStyle {
        let style: PresentationStyle
        let vc = vc as? Presentable

        switch traitCollection.horizontalSizeClass {
        case .regular:
            style = vc?.iPadPresentationStyle ?? .pageSheet
        case .compact:
            style = vc?.iPhonePresentationStyle ?? .modal
        case .unspecified:
            style = .modal
        }

        return style
    }

    // MARK: - Present as first screen in stack

    private
    func showActionSheet(_ vc: UIViewController, sender: Any?) {
        let actionSheetTemplate = ActionSheetTemplate()
        actionSheetTemplate.delegate = self

        addChild(actionSheetTemplate)
        actionSheetTemplate.addChild(vc)

        view.addSubview(actionSheetTemplate.view)
        actionSheetTemplate.dummyView.addSubview(vc.view)

        actionSheetTemplate.view.translatesAutoresizingMaskIntoConstraints = false
        vc.view.translatesAutoresizingMaskIntoConstraints = false

        containerConstraints = [
            self.view.leading.constraint(equalTo: actionSheetTemplate.view.leading),
            self.view.trailing.constraint(equalTo: actionSheetTemplate.view.trailing),
            self.view.top.constraint(equalTo: actionSheetTemplate.view.top),
            self.view.bottom.constraint(equalTo: actionSheetTemplate.view.bottom),
        ]

        NSLayoutConstraint.activate(containerConstraints)
        actionSheetTemplate.view.layoutIfNeeded()

        let constraints = [
            actionSheetTemplate.dummyView.leading.constraint(equalTo: vc.view.leading),
            actionSheetTemplate.dummyView.trailing.constraint(equalTo: vc.view.trailing),
            actionSheetTemplate.dummyView.top.constraint(equalTo: vc.view.top),
            actionSheetTemplate.dummyView.bottom.constraint(equalTo: vc.view.bottom),
        ]
        NSLayoutConstraint.activate(constraints)

        actionSheetTemplate.didMove(toParent: self)
        vc.didMove(toParent: actionSheetTemplate)

        appendIfNeeded(vc)
        self.actionSheetTemplate = actionSheetTemplate
    }

    private func showModal(_ vc: UIViewController, sender: Any?) {
        let modalTemplate = ModalTemplate()
        modalTemplate.delegate = self

        addChild(modalTemplate)
        modalTemplate.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(modalTemplate.view)

        modalTemplate.addChild(vc)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        modalTemplate.setContentView(vc.view)

        let modalTemplateConstraints = [
            view.leading.constraint(equalTo: modalTemplate.view.leading),
            view.trailing.constraint(equalTo: modalTemplate.view.trailing),
            view.top.constraint(equalTo: modalTemplate.view.top),
            view.bottom.constraint(equalTo: modalTemplate.view.bottom),
        ]

        modalTemplateConstraints.forEach { $0.priority = .highest }

        NSLayoutConstraint.activate(modalTemplateConstraints)
        modalTemplate.view.layoutIfNeeded()

        modalTemplate.didMove(toParent: self)
        vc.didMove(toParent: modalTemplate)

        let hasNavigationBar = (vc as? Presentable)?.hasNavigationBar ?? true
        modalTemplate.setNavigationBarHidden(hasNavigationBar == false, animated: false)
        modalTemplate.setNavigationItems(modules.map { $0.navigationItem }, animated: false)
        modalTemplate.view.layoutIfNeeded()

        appendIfNeeded(vc)
        self.modalTemplate = modalTemplate
    }

    private func showPageSheet(_ vc: UIViewController, sender: Any?) {
        let pageSheet = PageSheetTemplate()
        pageSheet.delegate = self

        addChild(pageSheet)
        pageSheet.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageSheet.view)

        pageSheet.addChild(vc)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        pageSheet.setContentView(vc.view)

        let modalTemplateConstraints = [
            view.leading.constraint(equalTo: pageSheet.view.leading),
            view.trailing.constraint(equalTo: pageSheet.view.trailing),
            view.top.constraint(equalTo: pageSheet.view.top),
            view.bottom.constraint(equalTo: pageSheet.view.bottom),
        ]
        NSLayoutConstraint.activate(modalTemplateConstraints)
        let hasNavigationBar = (vc as? Presentable)?.hasNavigationBar ?? true
        pageSheet.setNavigationBarHidden(hasNavigationBar == false, animated: false)
        pageSheet.setNavigationItems(modules.map { $0.navigationItem }, animated: false)
        pageSheet.view.layoutIfNeeded()

        pageSheet.didMove(toParent: self)
        vc.didMove(toParent: pageSheet)

        vc.removeKeyboardObservers()

        appendIfNeeded(vc)
        self.pageSheetTemplate = pageSheet
    }

    // MARK: - Hide view controller without animation

    private func hide(actionSheet: ActionSheetTemplate) {
        hideContainer(actionSheet)
        self.actionSheetTemplate = nil
    }

    private func hide(modal: ModalTemplate) {
        hideContainer(modal)
        self.modalTemplate = nil
    }

    private func hide(pageSheet: PageSheetTemplate) {
        hideContainer(pageSheet)
        self.pageSheetTemplate = nil
    }

    private func hideContainer(_ vc: UIViewController) {
        vc.willMove(toParent: nil)

        containerConstraints = []

        vc.view.removeFromSuperview()
        vc.removeFromParent()
    }

    // MARK: - Hide view controller animated

    private func hideAnimated(actionSheet: ActionSheetTemplate, completion: (() -> Void)? = nil) {
        actionSheet.willMove(toParent: nil)

        NSLayoutConstraint.deactivate(containerConstraints)

        let constraints = [
            actionSheet.view.leading.constraint(equalTo: view.leading),
            actionSheet.view.trailing.constraint(equalTo: view.trailing),
            actionSheet.view.height.constraint(equalTo: view.height),
            actionSheet.dummyView.top.constraint(equalTo: view.bottom),
        ]
        NSLayoutConstraint.activate(constraints)

        UIView.animate(withDuration: timeInterval,
                       animations: {
                           self.view.layoutIfNeeded()
                       },
                       completion: { _ in
                           actionSheet.view.removeFromSuperview()
                           actionSheet.removeFromParent()
                           self.actionSheetTemplate = nil
                           completion?()
                       })
    }

    private func hideAnimated(pageSheet: PageSheetTemplate, completion: (() -> Void)? = nil) {
        pageSheet.willMove(toParent: nil)
        NSLayoutConstraint.deactivate(containerConstraints)

        let dismissConstraint = [
            pageSheet.view.leading.constraint(equalTo: view.leading),
            pageSheet.view.trailing.constraint(equalTo: view.trailing),
            pageSheet.view.height.constraint(equalTo: view.height),
            pageSheet.dummyView.top.constraint(equalTo: view.bottom),
        ]
        NSLayoutConstraint.activate(dismissConstraint)

        UIView.animate(withDuration: timeInterval,
                       animations: {
                           self.view.layoutIfNeeded()
                       },
                       completion: { _ in
                           pageSheet.view.removeFromSuperview()
                           pageSheet.removeFromParent()
                           self.pageSheetTemplate = nil
                           completion?()
                       })
    }

    private func hideAnimated(modalTemplate: ModalTemplate, completion: (() -> Void)? = nil) {
        modalTemplate.willMove(toParent: nil)
        NSLayoutConstraint.deactivate(containerConstraints)

        let dismissConstraint = [
            modalTemplate.view.leading.constraint(equalTo: view.leading),
            modalTemplate.view.trailing.constraint(equalTo: view.trailing),
            modalTemplate.view.height.constraint(equalTo: view.height),
            modalTemplate.view.top.constraint(equalTo: view.bottom),
        ]
        NSLayoutConstraint.activate(dismissConstraint)

        UIView.animate(withDuration: timeInterval,
                       animations: {
                           self.view.layoutIfNeeded()
                       },
                       completion: { _ in
                           modalTemplate.view.removeFromSuperview()
                           modalTemplate.removeFromParent()
                           self.modalTemplate = nil
                           completion?()
                       })
    }

    // MARK: - Present view controller animated

    private func presentModalAnimated(_ vc: UIViewController, completion: (() -> Void)? = nil) {
        let modalTemplate = ModalTemplate()
        modalTemplate.delegate = self

        appendIfNeeded(vc)

        addChild(modalTemplate)
        modalTemplate.view.translatesAutoresizingMaskIntoConstraints = false
        modalTemplate.view.frame = view.bounds
        view.addSubview(modalTemplate.view)

        modalTemplate.addChild(vc)
        modalTemplate.setContentView(vc.view)

        let startConstraints = [
            modalTemplate.view.leading.constraint(equalTo: view.leading),
            modalTemplate.view.top.constraint(equalTo: view.bottom),
            modalTemplate.view.width.constraint(equalTo: view.width),
            modalTemplate.view.height.constraint(equalTo: view.height),
        ]

        NSLayoutConstraint.activate(startConstraints)
        view.layoutIfNeeded()

        let endConstraints = [
            modalTemplate.view.leading.constraint(equalTo: view.leading),
            modalTemplate.view.trailing.constraint(equalTo: view.trailing),
            modalTemplate.view.top.constraint(equalTo: view.top),
            modalTemplate.view.bottom.constraint(equalTo: view.bottom),
        ]

        endConstraints.forEach { $0.priority = .highest }

        NSLayoutConstraint.deactivate(startConstraints)
        NSLayoutConstraint.activate(endConstraints)

        modalTemplate.setNavigationItems(modules.map { $0.navigationItem }, animated: false)

        UIView.animate(withDuration: timeInterval,
                       animations: {
                           self.view.layoutIfNeeded()
                       },
                       completion: { _ in
                           modalTemplate.didMove(toParent: self)
                           vc.didMove(toParent: modalTemplate)

                           self.modalTemplate = modalTemplate
                           completion?()
                       })
    }

    private func presentPageSheetAnimated(_ vc: UIViewController, completion: (() -> Void)? = nil) {
        let pageSheet = PageSheetTemplate()
        pageSheet.delegate = self

        addChild(pageSheet)
        pageSheet.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageSheet.view)

        pageSheet.addChild(vc)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        pageSheet.setContentView(vc.view)

        let startConstraints = [
            pageSheet.view.leading.constraint(equalTo: view.leading),
            pageSheet.view.top.constraint(equalTo: view.bottom),
            pageSheet.view.width.constraint(equalTo: view.width),
            pageSheet.view.height.constraint(equalTo: view.height),
        ]

        NSLayoutConstraint.activate(startConstraints)
        view.layoutIfNeeded()

        let endConstraints = [
            pageSheet.view.leading.constraint(equalTo: view.leading),
            pageSheet.view.trailing.constraint(equalTo: view.trailing),
            pageSheet.view.top.constraint(equalTo: view.top),
            pageSheet.view.bottom.constraint(equalTo: view.bottom),
        ]

        NSLayoutConstraint.deactivate(startConstraints)
        NSLayoutConstraint.activate(endConstraints)

        let hasNavigationBar = (vc as? Presentable)?.hasNavigationBar ?? true
        pageSheet.setNavigationBarHidden(hasNavigationBar == false, animated: false)
        pageSheet.setNavigationItems(modules.map { $0.navigationItem }, animated: false)

        UIView.animate(withDuration: timeInterval,
                       animations: {
                           self.view.layoutIfNeeded()
                       },
                       completion: { _ in
                           pageSheet.didMove(toParent: self)
                           vc.didMove(toParent: pageSheet)

                           vc.removeKeyboardObservers()

                           self.pageSheetTemplate = pageSheet
                           completion?()
                       })

        appendIfNeeded(vc)
    }

    private func presentActionSheetAnimated(_ vc: UIViewController, completion: (() -> Void)? = nil) {
        let actionSheetTemplate = ActionSheetTemplate()
        actionSheetTemplate.delegate = self

        addChild(actionSheetTemplate)
        actionSheetTemplate.addChild(vc)
        vc.didMove(toParent: actionSheetTemplate)

        view.addSubview(actionSheetTemplate.view)
        actionSheetTemplate.dummyView.addSubview(vc.view)

        actionSheetTemplate.view.translatesAutoresizingMaskIntoConstraints = false
        vc.view.translatesAutoresizingMaskIntoConstraints = false

        let dummyViewConstraints = [
            actionSheetTemplate.dummyView.leading.constraint(equalTo: vc.view.leading),
            actionSheetTemplate.dummyView.trailing.constraint(equalTo: vc.view.trailing),
            actionSheetTemplate.dummyView.top.constraint(equalTo: vc.view.top),
            actionSheetTemplate.dummyView.bottom.constraint(equalTo: vc.view.bottom),
        ]

        NSLayoutConstraint.activate(dummyViewConstraints)

        let startConstraints = [
            actionSheetTemplate.view.leading.constraint(equalTo: view.leading),
            actionSheetTemplate.view.top.constraint(equalTo: view.bottom),
            actionSheetTemplate.view.width.constraint(equalTo: view.width),
            actionSheetTemplate.view.height.constraint(equalTo: view.height),
        ]

        NSLayoutConstraint.activate(startConstraints)
        view.layoutIfNeeded()

        let endConstraints = [
            actionSheetTemplate.view.leading.constraint(equalTo: view.leading),
            actionSheetTemplate.view.trailing.constraint(equalTo: view.trailing),
            actionSheetTemplate.view.top.constraint(equalTo: view.top),
            actionSheetTemplate.view.bottom.constraint(equalTo: view.bottom),
        ]

        NSLayoutConstraint.deactivate(startConstraints)
        NSLayoutConstraint.activate(endConstraints)

        UIView.animate(withDuration: timeInterval,
                       animations: {
                           self.view.layoutIfNeeded()
                       },
                       completion: { _ in
                           actionSheetTemplate.didMove(toParent: self)
                           completion?()
                       })

        appendIfNeeded(vc)
        self.actionSheetTemplate = actionSheetTemplate
    }

    // MARK: - Push without change container

    private func pushActionSheet(_ actionSheetTemplate: ActionSheetTemplate,
                                 previous pvc: UIViewController,
                                 next nvc: UIViewController,
                                 sender: Any?) {
        pvc.willMove(toParent: nil)
        actionSheetTemplate.addChild(nvc)

        nvc.view.translatesAutoresizingMaskIntoConstraints = false

        actionSheetTemplate.dummyView.addSubview(nvc.view)

        let startConstraints = [
            nvc.view.leading.constraint(equalTo: pvc.view.trailing),
            nvc.view.top.constraint(equalTo: pvc.view.top),
            nvc.view.width.constraint(equalTo: pvc.view.width),
            nvc.view.height.constraint(equalTo: pvc.view.height),
        ]

        NSLayoutConstraint.activate(startConstraints)
        actionSheetTemplate.dummyView.setNeedsLayout()
        actionSheetTemplate.dummyView.layoutIfNeeded()

        let endConstraints = [
            actionSheetTemplate.dummyView.leading.constraint(equalTo: nvc.view.leading),
            actionSheetTemplate.dummyView.trailing.constraint(equalTo: nvc.view.trailing),
            actionSheetTemplate.dummyView.top.constraint(equalTo: nvc.view.top),
            actionSheetTemplate.dummyView.bottom.constraint(equalTo: nvc.view.bottom),
        ]

        NSLayoutConstraint.deactivate(startConstraints)
        NSLayoutConstraint.activate(endConstraints)

        pvc.view.isUserInteractionEnabled = false
        UIView.animate(withDuration: timeInterval,
                       animations: {
                           actionSheetTemplate.dummyView.layoutIfNeeded()
                       },
                       completion: { _ in
                           pvc.view.removeFromSuperview()
                           pvc.removeFromParent()

                           nvc.didMove(toParent: actionSheetTemplate)
                           pvc.view.isUserInteractionEnabled = true
                           self.appendIfNeeded(nvc)
                       })
    }

    private func pushPageSheet(_ pageSheet: PageSheetTemplate,
                               previous pvc: UIViewController,
                               next nvc: UIViewController,
                               sender: Any?) {
        pvc.willMove(toParent: nil)
        pageSheet.addChild(nvc)

        nvc.view.translatesAutoresizingMaskIntoConstraints = false

        pageSheet.dummyView.addSubview(nvc.view)

        nvc.removeKeyboardObservers()

        let startConstraints = [
            nvc.view.leading.constraint(equalTo: pvc.view.trailing),
            nvc.view.top.constraint(equalTo: pvc.view.top),
            nvc.view.width.constraint(equalTo: pvc.view.width),
            nvc.view.height.constraint(equalTo: pvc.view.height),
        ]

        NSLayoutConstraint.activate(startConstraints)
        pageSheet.dummyView.setNeedsLayout()
        pageSheet.dummyView.layoutIfNeeded()

        NSLayoutConstraint.deactivate(startConstraints)
        pageSheet.setContentView(nvc.view)

        let hasNavigationBar = (nvc as? Presentable)?.hasNavigationBar ?? true
        pageSheet.pushNavigationItem(nvc.navigationItem, animated: false)
        pageSheet.setNavigationBarHidden(hasNavigationBar == false, animated: false)

        pvc.view.isUserInteractionEnabled = false
        UIView.animate(withDuration: timeInterval,
                       animations: {
                           pageSheet.dummyView.layoutIfNeeded()
                       },
                       completion: { _ in
                           pvc.view.removeFromSuperview()
                           UIView.animate(withDuration: timeInterval,
                                          animations: {
                                              pageSheet.view.layoutIfNeeded()
                                          },
                                          completion: { _ in
                                              nvc.didMove(toParent: pageSheet)
                                          })

                           pvc.removeFromParent()
                           pvc.view.isUserInteractionEnabled = true
                           self.appendIfNeeded(nvc)
                       })
    }

    private func pushModal(_ modal: ModalTemplate,
                           previous pvc: UIViewController,
                           next nvc: UIViewController,
                           sender: Any?) {
        pvc.willMove(toParent: nil)
        modal.addChild(nvc)

        nvc.view.translatesAutoresizingMaskIntoConstraints = false

        modal.view.insertSubview(nvc.view, belowSubview: modal.navigationBar)

        nvc.removeKeyboardObservers()

        let startConstraints = [
            nvc.view.leading.constraint(equalTo: pvc.view.trailing),
            nvc.view.top.constraint(equalTo: pvc.view.top),
            nvc.view.width.constraint(equalTo: pvc.view.width),
            nvc.view.height.constraint(equalTo: pvc.view.height),
        ]

        NSLayoutConstraint.activate(startConstraints)
        modal.view.setNeedsLayout()
        modal.view.layoutIfNeeded()

        NSLayoutConstraint.deactivate(startConstraints)
        modal.setContentView(nvc.view)

        let hasNavigationBar = (nvc as? Presentable)?.hasNavigationBar ?? true
        modal.pushNavigationItem(nvc.navigationItem, animated: false)
        modal.setNavigationBarHidden(hasNavigationBar == false, animated: true)

        nvc.view.layer.shadowOffset = CGSize(width: -3, height: 0)

        pvc.view.isUserInteractionEnabled = false
        UIView.animateKeyframes(withDuration: timeInterval,
                                delay: 0,
                                options: .calculationModeCubicPaced,
                                animations: {
                                    UIView.addKeyframe(withRelativeStartTime: 0,
                                                       relativeDuration: timeInterval / 2,
                                                       animations: {
                                                           nvc.view.layer.shadowOpacity = 1.0
                                                       })
                                    UIView.addKeyframe(withRelativeStartTime: timeInterval / 2,
                                                       relativeDuration: timeInterval / 2,
                                                       animations: {
                                                           nvc.view.layer.shadowOpacity = 0.0
                                                       })
                                    UIView.addKeyframe(withRelativeStartTime: 0,
                                                       relativeDuration: timeInterval,
                                                       animations: {
                                                           modal.view.layoutIfNeeded()
                                                       })
                                },
                                completion: { _ in
                                    pvc.view.removeFromSuperview()
                                    pvc.removeFromParent()

                                    nvc.didMove(toParent: modal)

                                    pvc.view.isUserInteractionEnabled = true
                                    self.appendIfNeeded(nvc)
                                })
    }

    // MARK: - Pop without changing container

    private func popModal(_ modal: ModalTemplate,
                          current cvc: UIViewController,
                          previous pvc: UIViewController,
                          sender: Any?) {
        cvc.willMove(toParent: nil)
        modal.addChild(pvc)

        pvc.removeKeyboardObservers()

        let previousView: UIView = pvc.view

        modal.setContentView(previousView)
        modal.view.setNeedsLayout()
        modal.view.layoutIfNeeded()

        let currentView: UIView = cvc.view
        let finishConstraints = [
            currentView.top.constraint(equalTo: previousView.top),
            currentView.leading.constraint(equalTo: previousView.trailing),
            currentView.width.constraint(equalTo: previousView.width),
            currentView.height.constraint(equalTo: previousView.height),
        ]

        let filter: (NSLayoutConstraint) -> Bool = {
            let items = [$0.firstItem, $0.secondItem].compactMap { $0 }
            return items.contains(where: { $0 === modal.view }) && items.contains(where: { $0 === currentView })
        }

        NSLayoutConstraint.deactivate(modal.view.constraints.filter(filter))
        NSLayoutConstraint.activate(finishConstraints)

        let hasNavigationBar = (pvc as? Presentable)?.hasNavigationBar ?? true

        modal.setNavigationBarHidden(hasNavigationBar == false, animated: false)

        UIView.animate(withDuration: timeInterval,
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: {
                           modal.view.layoutIfNeeded()
                       },
                       completion: { _ in
                           currentView.removeFromSuperview()
                           cvc.removeFromParent()
                           pvc.didMove(toParent: modal)

                           self.modules.removeLast()
                       })
    }

    private func popPageSheet(_ pageSheet: PageSheetTemplate,
                              current cvc: UIViewController,
                              previous pvc: UIViewController,
                              sender: Any?) {
        cvc.willMove(toParent: nil)
        pageSheet.addChild(pvc)

        pvc.removeKeyboardObservers()

        let previousView: UIView = pvc.view

        pageSheet.setContentView(previousView)
        pageSheet.view.setNeedsLayout()
        pageSheet.view.layoutIfNeeded()

        let currentView: UIView = cvc.view
        let finishConstraints = [
            currentView.top.constraint(equalTo: previousView.top),
            currentView.leading.constraint(equalTo: previousView.trailing),
            currentView.width.constraint(equalTo: previousView.width),
            currentView.height.constraint(equalTo: previousView.height),
        ]

        let filter: (NSLayoutConstraint) -> Bool = {
            let items = [$0.firstItem, $0.secondItem].compactMap { $0 }
            return items.contains(where: { $0 === pageSheet.view }) && items.contains(where: { $0 === currentView })
        }

        NSLayoutConstraint.deactivate(pageSheet.view.constraints.filter(filter))
        NSLayoutConstraint.activate(finishConstraints)

        let hasNavigationBar = (pvc as? Presentable)?.hasNavigationBar ?? true

        pageSheet.setNavigationBarHidden(hasNavigationBar == false, animated: false)

        UIView.animate(withDuration: timeInterval,
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: {
                           pageSheet.view.layoutIfNeeded()
                       },
                       completion: { _ in
                           currentView.removeFromSuperview()
                           cvc.removeFromParent()
                           pvc.didMove(toParent: pageSheet)

                           self.modules.removeLast()
                       })
    }

    // MARK: - Managing modules

    private func appendIfNeeded(_ module: UIViewController) {
        guard module !== modules.last else { return }
        modules.append(module)
    }
}

extension TokenizationViewController: ActionSheetTemplateDelegate {
    func actionSheetTemplateDidFinish(_ template: ActionSheetTemplate) {
        output?.closeDidPress()
    }
}

extension TokenizationViewController: PageSheetTemplateDelegate {
    func pageSheetTemplateDidFinish(_ template: PageSheetTemplate) {
        output?.closeDidPress()
    }
}

extension TokenizationViewController: ModalTemplateDelegate {
    func shouldPopNavigationItem() {
        popViewController(animated: true)
    }
}

// MARK: - TokenizationModuleInput

extension TokenizationViewController: TokenizationModuleInput {
    func start3dsProcess(requestUrl: String, redirectUrl: String) {
        output.start3dsProcess(requestUrl: requestUrl, redirectUrl: redirectUrl)
    }

    func start3dsProcess(requestUrl: String) {
        output.start3dsProcess(requestUrl: requestUrl)
    }
}

// MARK: - PKPaymentAuthorizationViewController - Presentable

extension PKPaymentAuthorizationViewController: Presentable {

    var iPhonePresentationStyle: PresentationStyle {
        return .applePay
    }

    var iPadPresentationStyle: PresentationStyle {
        return .applePay
    }

    public var hasNavigationBar: Bool {
        return false
    }
}
