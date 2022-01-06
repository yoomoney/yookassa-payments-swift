class CardSecInteractor {

    private let options = WebBrowserOptions.all

    // MARK: - VIPER

    weak var output: WebBrowserInteractorOutput?
    weak var cardSecPresenter: CardSecInteractorOutput?

    // MARK: - Init data

    private let analyticsService: AnalyticsTracking
    private let requestUrl: String
    private let redirectUrl: String
    private let logger: WebLoggerService

    // MARK: - Init

    init(
        analyticsService: AnalyticsTracking,
        requestUrl: String,
        redirectUrl: String,
        logger: WebLoggerService
    ) {
        self.analyticsService = analyticsService
        self.requestUrl = requestUrl
        self.redirectUrl = redirectUrl
        self.logger = logger
    }

    // MARK: - Properties

    fileprivate lazy var redirectPaths = [
        redirectUrl,
    ]
}

// MARK: - WebBrowserInteractorInput

extension CardSecInteractor: WebBrowserInteractorInput {
    func createRequest() {
        guard let output = output,
              let url = URL(string: requestUrl) else {
            return
        }

        output.didCreateRequest(URLRequest(url: url), options)
    }

    func shouldProcessRequest(_ request: URLRequest) -> Bool {
        logger.trace(request)
        let path = request.url?.absoluteString ?? ""
        let availableRedirects = redirectPaths.filter { path.hasPrefix($0) == true }
        return availableRedirects.isEmpty == false
    }

    func processRequest(_ request: URLRequest) {
        cardSecPresenter?.didSuccessfullyPassedCardSec()
    }
}

// MARK: - CardSecInteractorInput

extension CardSecInteractor: CardSecInteractorInput {
    func track(event: AnalyticsEvent) {
        analyticsService.track(event: event)
    }
}
