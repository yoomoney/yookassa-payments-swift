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
        if shouldCallDidSuccessfullyPassedCardSec {
            cardSecInteractor.track(event: .screen3dsClose(success: false))
        }
    }

    override func viewWillDisappear() {
        cardSecModuleOutput?.viewWillDisappear()
    }

    private func trackAnalyticsEvent() {
        cardSecInteractor.track(event: .screen3ds)
    }
}

// MARK: - CardSecInteractorOutput

extension CardSecPresenter: CardSecInteractorOutput {
    func didSuccessfullyPassedCardSec() {
        guard shouldCallDidSuccessfullyPassedCardSec else { return }
        shouldCallDidSuccessfullyPassedCardSec = false
        cardSecInteractor.track(event: .screen3dsClose(success: true))
        cardSecModuleOutput?.didSuccessfullyPassedCardSec(on: self)
    }
}

// MARK: - CardSecModuleInput

extension CardSecPresenter: CardSecModuleInput {}
