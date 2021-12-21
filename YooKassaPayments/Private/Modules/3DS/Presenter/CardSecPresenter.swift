final class CardSecPresenter: WebBrowserPresenter {

    // MARK: - VIPER

    var cardSecInteractor: CardSecInteractorInput!
    weak var cardSecModuleOutput: CardSecModuleOutput?

    // MARK: - Business logic properties

    private var shouldCallDidSuccessfullyPassedCardSec = true

    // MARK: - Overridden funcs

    override func setupView() {
        super.setupView()
        trackAnalyticsEvent()
    }

    override func didPressCloseButton() {
        cardSecModuleOutput?.didPressCloseButton(on: self)
    }

    override func viewWillDisappear() {
        cardSecModuleOutput?.viewWillDisappear()
    }

    private func trackAnalyticsEvent() {
        let event: AnalyticsEvent = .screen3ds(
            sdkVersion: Bundle.frameworkVersion
        )
        cardSecInteractor.trackEvent(event)
    }
}

// MARK: - CardSecInteractorOutput

extension CardSecPresenter: CardSecInteractorOutput {
    func didSuccessfullyPassedCardSec() {
        guard shouldCallDidSuccessfullyPassedCardSec else { return }
        shouldCallDidSuccessfullyPassedCardSec = false
        cardSecModuleOutput?.didSuccessfullyPassedCardSec(on: self)
    }
}

// MARK: - CardSecModuleInput

extension CardSecPresenter: CardSecModuleInput {}
