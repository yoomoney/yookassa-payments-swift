import UIKit

final class SheetContentViewController: UIViewController {

    // MARK: - SheetContentViewDelegate

    weak var delegate: SheetContentViewDelegate?

    // MARK: - UI properties

    lazy var contentView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIView())

    private lazy var contentWrapperView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.masksToBounds = true
        if #available(iOS 11.0, *) {
            $0.layer.maskedCorners = [
                .layerMaxXMinYCorner,
                .layerMinXMinYCorner,
            ]
        }
        return $0
    }(UIView())

    private lazy var pullBarView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIView())

    private lazy var gripView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIView())

    private lazy var overflowView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIView())

    private lazy var childContainerView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            $0.backgroundColor = UIColor.systemBackground
        } else {
            $0.backgroundColor = UIColor.white
        }
        $0.layer.masksToBounds = true
        if #available(iOS 11.0, *) {
            $0.layer.maskedCorners = [
                .layerMaxXMinYCorner,
                .layerMinXMinYCorner,
            ]
        }
        return $0
    }(UIView())

    // MARK: - NSLayoutConstraint

    private lazy var contentTopConstraint: NSLayoutConstraint = {
        return contentView.topAnchor.constraint(equalTo: view.topAnchor)
    }()

    private lazy var contentBottomConstraint: NSLayoutConstraint = {
        return childViewController.view.bottomAnchor.constraint(equalTo: childContainerView.bottomAnchor)
    }()

    private var navigationHeightConstraint: NSLayoutConstraint?
    private var gripSizeConstraints: [NSLayoutConstraint] = []

    // MARK: - Logic properties

    private(set) var preferredHeight: CGFloat = 0

    // MARK: - Notification center

    private let notificationCenter = NotificationCenter.default

    // MARK: - Initialization

    private let childViewController: UIViewController
    private let options: SheetOptions
    private let cornerRadius: CGFloat
    private let gripSize: CGSize
    private let gripColor: UIColor
    private let pullBarBackgroundColor: UIColor
    private let treatPullBarAsClear: Bool

    init(
        childViewController: UIViewController,
        sheetViewModel: SheetViewModel,
        options: SheetOptions
    ) {
        self.childViewController = childViewController
        self.options = options

        cornerRadius = sheetViewModel.cornerRadius
        gripSize = sheetViewModel.gripSize
        gripColor = sheetViewModel.gripColor
        pullBarBackgroundColor = sheetViewModel.pullBarBackgroundColor
        treatPullBarAsClear = sheetViewModel.treatPullBarAsClear

        super.init(nibName: nil, bundle: nil)

        if let navigationController = self.childViewController as? UINavigationController {
            navigationController.delegate = self
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Managing the View

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNotificationCenter()
        setupContentView()
        setupChildContainerView()
        setupChildViewController()
        setupOverflowView()
        setupGripSize()
        setupGripColor()
        setupPullBarView()

        updatePreferredHeight()
        setupCornerRadius()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.performWithoutAnimation {
            view.layoutIfNeeded()
        }
        updatePreferredHeight()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updatePreferredHeight()
    }

    // MARK: - SetupView

    private func setupNotificationCenter() {
        notificationCenter.addObserver(
            self,
            selector: #selector(needUpdatePreferredHeight),
            name: .needUpdatePreferredHeight,
            object: nil
        )
    }

    private func setupContentView() {
        view.addSubview(contentView)
        contentView.addSubview(contentWrapperView)
        contentView.addSubview(overflowView)

        NSLayoutConstraint.activate([
            contentTopConstraint,
            contentView.leftAnchor.constraint(equalTo: view.leftAnchor),
            contentView.rightAnchor.constraint(equalTo: view.rightAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentWrapperView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            contentWrapperView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            contentWrapperView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            contentWrapperView.topAnchor.constraint(equalTo: contentView.topAnchor),

            overflowView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            overflowView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            overflowView.heightAnchor.constraint(equalToConstant: 200),
            overflowView.topAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -1
            ),
        ])
    }

    private func setupChildContainerView() {
        contentWrapperView.addSubview(childContainerView)

        NSLayoutConstraint.activate([
            childContainerView.topAnchor.constraint(
                equalTo: contentWrapperView.topAnchor,
                constant: options.pullBarHeight
            ),
            childContainerView.leftAnchor.constraint(equalTo: contentWrapperView.leftAnchor),
            childContainerView.rightAnchor.constraint(equalTo: contentWrapperView.rightAnchor),
            childContainerView.bottomAnchor.constraint(equalTo: contentWrapperView.bottomAnchor),
        ])
    }

    private func setupChildViewController() {
        childViewController.willMove(toParent: self)
        addChild(childViewController)
        childContainerView.addSubview(childViewController.view)

        childViewController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            childViewController.view.leadingAnchor.constraint(equalTo: childContainerView.leadingAnchor),
            childViewController.view.trailingAnchor.constraint(equalTo: childContainerView.trailingAnchor),
            childViewController.view.topAnchor.constraint(equalTo: childContainerView.topAnchor),
            contentBottomConstraint,
        ])

        childViewController.didMove(toParent: self)
    }

    private func setupOverflowView() {
        overflowView.backgroundColor = childViewController.view.backgroundColor
    }

    private func setupGripSize() {
        NSLayoutConstraint.deactivate(gripSizeConstraints)
        gripSizeConstraints = [
            gripView.heightAnchor.constraint(equalToConstant: gripSize.height),
            gripView.widthAnchor.constraint(equalToConstant: gripSize.width),
        ]
        NSLayoutConstraint.activate(gripSizeConstraints)
        gripView.layer.cornerRadius = gripSize.height / 2
    }

    private func setupGripColor() {
        gripView.backgroundColor = gripColor
    }

    private func setupPullBarView() {
        guard options.pullBarHeight > 0 else { return }
        let pullBarView = self.pullBarView
        pullBarView.isUserInteractionEnabled = true
        pullBarView.backgroundColor = pullBarBackgroundColor
        contentWrapperView.addSubview(pullBarView)
        NSLayoutConstraint.activate([
            pullBarView.topAnchor.constraint(equalTo: contentWrapperView.topAnchor),
            pullBarView.leftAnchor.constraint(equalTo: contentWrapperView.leftAnchor),
            pullBarView.rightAnchor.constraint(equalTo: contentWrapperView.rightAnchor),
            pullBarView.heightAnchor.constraint(equalToConstant: options.pullBarHeight),
        ])
        self.pullBarView = pullBarView

        let gripView = self.gripView
        gripView.backgroundColor = gripColor
        gripView.layer.cornerRadius = gripSize.height / 2
        gripView.layer.masksToBounds = true
        pullBarView.addSubview(gripView)
        NSLayoutConstraint.deactivate(gripSizeConstraints)
        gripSizeConstraints = [
            gripView.heightAnchor.constraint(equalToConstant: gripSize.height),
            gripView.widthAnchor.constraint(equalToConstant: gripSize.width),
        ]
        NSLayoutConstraint.activate([
            gripView.centerYAnchor.constraint(equalTo: pullBarView.centerYAnchor),
            gripView.centerXAnchor.constraint(equalTo: pullBarView.centerXAnchor),
        ])
        NSLayoutConstraint.activate(gripSizeConstraints)
    }

    private func setupCornerRadius() {
        contentWrapperView.layer.cornerRadius = treatPullBarAsClear
            ? 0
            : cornerRadius
        childContainerView.layer.cornerRadius = treatPullBarAsClear
            ? cornerRadius
            : 0
    }

    // MARK: - Actions

    @objc
    private func needUpdatePreferredHeight(
        _ notification: Notification
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.updatePreferredHeight()
        }
    }
}

// MARK: - Internal helpers

extension SheetContentViewController {
    func adjustForKeyboard(
        height: CGFloat
    ) {
        updateChildViewControllerBottomConstraint(
            adjustment: -height
        )
    }

    func updatePreferredHeight() {
        updateNavigationControllerHeight()
        let width = view.bounds.width > 0
            ? view.bounds.width
            : UIScreen.main.bounds.width

        let oldPreferredHeight = preferredHeight
        var fittingSize = UIView.layoutFittingCompressedSize
        fittingSize.width = width
        contentTopConstraint.isActive = false

        UIView.performWithoutAnimation {
            contentView.layoutSubviews()
        }
        preferredHeight = contentView.systemLayoutSizeFitting(
            fittingSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .defaultLow
        ).height
        contentTopConstraint.isActive = true

        UIView.performWithoutAnimation {
            contentView.layoutSubviews()
        }

        delegate?.preferredHeightChanged(
            oldHeight: oldPreferredHeight,
            newSize: preferredHeight
        )
    }
}

// MARK: - Private helpers

private extension SheetContentViewController {
    func updateNavigationControllerHeight() {
        guard let navigationController = childViewController as? UINavigationController else { return }
        navigationHeightConstraint?.isActive = false
        contentTopConstraint.isActive = false

        if let viewController = navigationController.visibleViewController {
            let sizeFitting = CGSize(width: view.bounds.width, height: 0)
            let size = viewController.view.systemLayoutSizeFitting(sizeFitting)

            if navigationHeightConstraint == nil {
                navigationHeightConstraint = navigationController.view.heightAnchor.constraint(
                    equalToConstant: size.height
                )
            } else {
                navigationHeightConstraint?.constant = size.height
            }
        }
        navigationHeightConstraint?.isActive = true
        contentTopConstraint.isActive = true
    }

    func updateChildViewControllerBottomConstraint(
        adjustment: CGFloat
    ) {
        contentBottomConstraint.constant = adjustment
    }
}

// MARK: - UINavigationControllerDelegate

extension SheetContentViewController: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
    ) {
        navigationController.view.endEditing(true)

        let item = UIBarButtonItem(
            title: "",
            style: .plain,
            target: nil,
            action: nil
        )
        viewController.navigationItem.backBarButtonItem = item
    }

    func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        navigationHeightConstraint?.isActive = true
        updatePreferredHeight()
    }
}

extension Notification.Name {
    static var needUpdatePreferredHeight: Notification.Name {
        return .init(rawValue: "SheetView.needUpdatePreferredHeight")
    }
}
