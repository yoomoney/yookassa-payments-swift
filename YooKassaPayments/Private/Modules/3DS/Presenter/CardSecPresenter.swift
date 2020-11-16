final class CardSecPresenter: WebBrowserPresenter {

    // MARK: - VIPER module properties

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

    private func trackAnalyticsEvent() {
        cardSecInteractor.trackEvent(.screen3ds)
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
