import Foundation
import FunctionalSwift

class CardSecInteractor {

    fileprivate let options = WebBrowserOptions.all

    // MARK: - VIPER module

    weak var output: WebBrowserInteractorOutput?
    weak var cardSecPresenter: CardSecInteractorOutput?

    // MARK: - VIPER module properties

    fileprivate let analyticsService: AnalyticsProcessing
    fileprivate let requestUrl: String
    fileprivate let redirectUrl: String

    fileprivate lazy var redirectPaths = [
        redirectUrl,
    ]

    init(analyticsService: AnalyticsProcessing, requestUrl: String, redirectUrl: String) {
        self.analyticsService = analyticsService
        self.requestUrl = requestUrl
        self.redirectUrl = redirectUrl
    }
}

// MARK: - WebBrowserInteractorInput

extension CardSecInteractor: WebBrowserInteractorInput {
    func createRequest() {
        func makeRequest(url: URL) -> URLRequest {
            return URLRequest(url: url)
        }

        let url = URL(string: requestUrl)

        guard let output = output,
              let request = makeRequest(url:) <^> url else {
            return
        }

        output.didCreateRequest(request, options)
    }

    func shouldProcessRequest(_ request: URLRequest) -> Bool {
        let path = request.url?.absoluteString ?? ""
        return redirectPaths.contains(path)
    }

    func processRequest(_ request: URLRequest) {
        cardSecPresenter?.didSuccessfullyPassedCardSec()
    }
}

// MARK: - CardSecInteractorInput

extension CardSecInteractor: CardSecInteractorInput {
    func trackEvent(_ event: AnalyticsEvent) {
        analyticsService.trackEvent(event)
    }
}
