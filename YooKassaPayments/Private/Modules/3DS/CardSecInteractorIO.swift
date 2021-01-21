protocol CardSecInteractorInput: AnalyticsTrack {}

protocol CardSecInteractorOutput: class {
    func didSuccessfullyPassedCardSec()
}
