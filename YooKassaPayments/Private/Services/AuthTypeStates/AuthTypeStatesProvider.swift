import struct YooKassaWalletApi.AuthTypeState

protocol AuthTypeStatesProvider: class {
    func filterStates(_ states: [AuthTypeState]) -> [AuthTypeState]
    func preferredAuthTypeState(_ states: [AuthTypeState]) throws -> AuthTypeState
}
