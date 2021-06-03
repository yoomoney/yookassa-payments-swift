protocol CardSecInteractorInput: AnalyticsTrack {}

protocol CardSecInteractorOutput: AnyObject {
    func didSuccessfullyPassedCardSec()
}
