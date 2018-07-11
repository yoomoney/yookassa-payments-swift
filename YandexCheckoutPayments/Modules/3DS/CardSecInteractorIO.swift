protocol CardSecInteractorInput: AnalyticsTrackable {}

protocol CardSecInteractorOutput: class {
    func didSuccessfullyPassedCardSec()
}
