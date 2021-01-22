final class AuthTypeStatesServiceImpl {}

// MARK: - AuthTypeStatesService

extension AuthTypeStatesServiceImpl: AuthTypeStatesService {
    func filterStates(_ states: [AuthTypeState]) -> [AuthTypeState] {
        return states.filter { $0.enabled && supportedTypes.keys.contains($0.specific.type) }
    }

    func preferredAuthTypeState(_ states: [AuthTypeState]) throws -> AuthTypeState {
        let sortedStates = states.sorted {
            supportedTypes[$0.specific.type] ?? -1 > supportedTypes[$1.specific.type] ?? -1
        }
        guard let state = sortedStates.first,
              supportedTypes.keys.contains(state.specific.type) else {
            throw WalletLoginProcessingError.unsupportedAuthType
        }
        return state
    }
}

private let supportedTypes: [AuthType: Int] = [
    .sms: 2,
    .totp: 1,
]
