import struct YandexCheckoutWalletApi.AuthTypeState

protocol AuthTypeStatesProvider: class {
    func filterStates(_ states: [AuthTypeState]) -> [AuthTypeState]
    func preferredAuthTypeState(_ states: [AuthTypeState]) throws -> AuthTypeState
}
