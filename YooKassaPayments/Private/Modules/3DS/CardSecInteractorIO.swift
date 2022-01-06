protocol CardSecInteractorInput {
    func track(event: AnalyticsEvent)
}

protocol CardSecInteractorOutput: AnyObject {
    func didSuccessfullyPassedCardSec()
}
