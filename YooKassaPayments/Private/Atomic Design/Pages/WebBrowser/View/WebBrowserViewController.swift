import UIKit
import WebKit.WKWebView

class WebBrowserViewController: UIViewController {
    var output: WebBrowserViewOutput! {
        didSet {
            webView.navigationDelegate = output
            webView.uiDelegate = output
        }
    }

    fileprivate lazy var webView: WKWebView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.scrollView.showsHorizontalScrollIndicator = false
        return $0
    }(WKWebView())

    fileprivate lazy var toolbar: UIToolbar = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIToolbar())

    fileprivate lazy var toolbarTopConstraint = toolbar.top.constraint(equalTo: view.bottom)

    fileprivate var isToolbarEmpty: Bool {
        guard let items = toolbar.items else { return true }
        return items.isEmpty
    }

    fileprivate lazy var backButton: UIBarButtonItem = {
        $0.isEnabled = false
        return $0
    }(UIBarButtonItem(image: UIImage.named("action_back"),
                      style: .plain,
                      target: self.webView,
                      action: #selector(WKWebView.goBack)))

    fileprivate lazy var forwardButton: UIBarButtonItem = {
        $0.isEnabled = false
        return $0
    }(UIBarButtonItem(image: UIImage.named("action_forward"),
                      style: .plain,
                      target: self.webView,
                      action: #selector(WKWebView.goForward)))

    fileprivate lazy var reloadButton: UIBarButtonItem = {
        return $0
    }(UIBarButtonItem(image: UIImage.named("action_refresh"),
                      style: .plain,
                      target: self.webView,
                      action: #selector(WKWebView.reload)))

    // MARK: - Managing the View

    override func loadView() {
        view = UIView()
        view.setStyles(UIView.Styles.defaultBackground)
        webView.setStyles(UIView.Styles.defaultBackground)
        webView.isOpaque = false
        addSubviews()
        setupConstraints()

        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        output.setupView()
        automaticallyAdjustsScrollViewInsets = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        webView.stopLoading()
        super.viewDidDisappear(animated)
    }

    // MARK: - Configuring the View’s Layout Behavior

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let scrollView = webView.scrollView
        scrollView.contentInset.bottom = isToolbarEmpty ? 0 : toolbar.frame.height
        scrollView.scrollIndicatorInsets = webView.scrollView.contentInset
    }

    @objc
    func closeButtonPressed() {
        output?.didPressCloseButton()
    }
}

// MARK: - Load view helpers

private extension WebBrowserViewController {
    func addSubviews() {
        view.addSubview(webView)
        view.addSubview(toolbar)
    }

    func setupConstraints() {
        let constraints = [
            webView.left.constraint(equalTo: view.left),
            webView.top.constraint(equalTo: view.top),
            webView.right.constraint(equalTo: view.right),
            webView.bottom.constraint(equalTo: view.bottom),
            toolbar.left.constraint(equalTo: view.left),
            toolbar.right.constraint(equalTo: view.right),
            toolbarTopConstraint,
        ]
        NSLayoutConstraint.activate(constraints)
    }
}

// MARK: - WebBrowserViewInput

extension WebBrowserViewController: WebBrowserViewInput {

    func setScreenName(_ screenName: String?) {
        title = screenName
    }

    func showRequest(_ request: URLRequest) {
        webView.load(request)
    }

    func updateToolBar() {
        backButton.isEnabled = webView.canGoBack
        forwardButton.isEnabled = webView.canGoForward
    }

    func setupToolBar(_ options: WebBrowserOptions) {
        setToolBar(options: options)
    }

    func setNavigationBar(_ options: WebBrowserOptions) {
        if options.contains(.close) {
            addCloseButtonIfNeeded(target: self, action: #selector(closeButtonPressed))
        }
    }
}

// MARK: - ActivityIndicatorFullViewPresenting

extension WebBrowserViewController: ActivityIndicatorFullViewPresenting {
    var activityContainerView: UIView {
        return webView
    }

    func showActivity() {
        showFullViewActivity(style: ActivityIndicatorView.Styles.light)
    }
}

// MARK: - Toolbar

private extension WebBrowserViewController {
    func setToolBar(options: WebBrowserOptions) {
        var items: [UIBarButtonItem] = []

        if options.contains(.navigation) {
            items += [backButton, forwardButton]
        }
        if options.contains(.update) {
            items += [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)]
            items += [reloadButton]
        }
        toolbar.setItems(items, animated: true)
        toolbar.layoutIfNeeded()
        toolbarTopConstraint.constant = isToolbarEmpty ? 0 : -toolbar.frame.height
        UIView.animate(withDuration: Constants.animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
}

private extension WebBrowserViewController {
    enum Constants {
        static let animationDuration: TimeInterval = 0.3
    }
}
