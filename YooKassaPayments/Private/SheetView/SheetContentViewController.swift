import UIKit

final class SheetContentViewController: UIViewController {

    // MARK: - SheetContentViewDelegate

    weak var delegate: SheetContentViewDelegate?

    // MARK: - UI properties

    var contentView = UIView()

    private var contentWrapperView = UIView()
    private var pullBarView = UIView()
    private var gripView = UIView()
    private let overflowView = UIView()

    private lazy var childContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            view.backgroundColor = UIColor.systemBackground
        } else {
            view.backgroundColor = UIColor.white
        }
        return view
    }()

    // MARK: - NSLayoutConstraint

    private var contentTopConstraint: NSLayoutConstraint?
    private var contentBottomConstraint: NSLayoutConstraint?
    private var navigationHeightConstraint: NSLayoutConstraint?
    private var gripSizeConstraints: [NSLayoutConstraint] = []

    // MARK: - Logic properties

    private(set) var preferredHeight: CGFloat = 0

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

    private func setupContentView() {
        view.addSubview(contentView)
        Constraints(for: contentView) {
            $0.left.pinToSuperview()
            $0.right.pinToSuperview()
            $0.bottom.pinToSuperview()
            contentTopConstraint = $0.top.pinToSuperview()
        }
        contentView.addSubview(contentWrapperView) {
            $0.edges.pinToSuperview()
        }

        contentWrapperView.layer.masksToBounds = true
        if #available(iOS 11.0, *) {
            contentWrapperView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        }

        contentView.addSubview(overflowView) {
            $0.edges(.left, .right).pinToSuperview()
            $0.height.set(200)
            $0.top.align(with: contentView.al.bottom - 1)
        }
    }

    private func setupChildContainerView() {
        contentWrapperView.addSubview(childContainerView)

        Constraints(for: childContainerView) { view in
            view.top.pinToSuperview(inset: options.pullBarHeight)
            view.left.pinToSuperview()
            view.right.pinToSuperview()
            view.bottom.pinToSuperview()
        }
    }

    private func setupChildViewController() {
        childViewController.willMove(toParent: self)
        addChild(childViewController)
        childContainerView.addSubview(childViewController.view)
        Constraints(for: childViewController.view) { view in
            view.left.pinToSuperview()
            view.right.pinToSuperview()
            contentBottomConstraint = view.bottom.pinToSuperview()
            view.top.pinToSuperview()
        }
        childViewController.didMove(toParent: self)

        childContainerView.layer.masksToBounds = true
        if #available(iOS 11.0, *) {
            childContainerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        }
    }

    private func setupOverflowView() {
        overflowView.backgroundColor = childViewController.view.backgroundColor
    }

    private func setupGripSize() {
        gripSizeConstraints.forEach({ $0.isActive = false })
        Constraints(for: gripView) {
            gripSizeConstraints = $0.size.set(gripSize)
        }
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
        Constraints(for: pullBarView) {
            $0.top.pinToSuperview()
            $0.left.pinToSuperview()
            $0.right.pinToSuperview()
            $0.height.set(options.pullBarHeight)
        }
        self.pullBarView = pullBarView

        let gripView = self.gripView
        gripView.backgroundColor = gripColor
        gripView.layer.cornerRadius = gripSize.height / 2
        gripView.layer.masksToBounds = true
        pullBarView.addSubview(gripView)
        gripSizeConstraints.forEach({ $0.isActive = false })
        Constraints(for: gripView) {
            $0.centerY.alignWithSuperview()
            $0.centerX.alignWithSuperview()
            gripSizeConstraints = $0.size.set(gripSize)
        }
    }

    private func setupCornerRadius() {
        contentWrapperView.layer.cornerRadius = treatPullBarAsClear
            ? 0
            : cornerRadius
        childContainerView.layer.cornerRadius = treatPullBarAsClear
            ? cornerRadius
            : 0
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
        var fittingSize = UIView.layoutFittingCompressedSize;
        fittingSize.width = width;
        contentTopConstraint?.isActive = false

        UIView.performWithoutAnimation {
            contentView.layoutSubviews()
        }
        preferredHeight = contentView.systemLayoutSizeFitting(
            fittingSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .defaultLow
        ).height
        contentTopConstraint?.isActive = true

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
        contentTopConstraint?.isActive = false

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
        contentTopConstraint?.isActive = true
    }

    func updateChildViewControllerBottomConstraint(
        adjustment: CGFloat
    ) {
        contentBottomConstraint?.constant = adjustment
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
