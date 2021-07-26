protocol AuthTypeStatesService: AnyObject {
    func filterStates(_ states: [AuthTypeState]) -> [AuthTypeState]
    func preferredAuthTypeState(_ states: [AuthTypeState]) throws -> AuthTypeState
}
