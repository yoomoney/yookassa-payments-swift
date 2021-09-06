import Foundation

protocol CardSettingsInteractorInput: AnyObject {
    func track(event: AnalyticsEvent)
    func unbind(id: String)
}

protocol CardSettingsInteractorOutput: AnyObject {
    func didUnbind(id: String)
    func didFailUnbind(error: Error, id: String)
}
