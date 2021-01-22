protocol AuthTypeStatesService: class {
    func filterStates(_ states: [AuthTypeState]) -> [AuthTypeState]
    func preferredAuthTypeState(_ states: [AuthTypeState]) throws -> AuthTypeState
}
