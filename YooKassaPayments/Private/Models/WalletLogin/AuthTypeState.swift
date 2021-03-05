import YooKassaWalletApi

/// Output format description of user authorization status
struct AuthTypeState {

    /// Specific description by type of authorization
    let specific: Specific

    /// Description of the active session.
    /// - note: `nil` - if no active session.
    let activeSession: ActiveSession?

    /// Whether it is possible to produce the type of authorization
    let canBeIssued: Bool

    /// A sign that the type of authorization available to the user
    let enabled: Bool

    /// A sign that for authentication type requires creation of a session
    let isSessionRequired: Bool

    init(
        specific: Specific,
        activeSession: ActiveSession?,
        canBeIssued: Bool,
        enabled: Bool,
        isSessionRequired: Bool
    ) {
        self.specific = specific
        self.activeSession = activeSession
        self.canBeIssued = canBeIssued
        self.enabled = enabled
        self.isSessionRequired = isSessionRequired
    }
}

// MARK: - AuthTypeState converter

extension AuthTypeState {
    init(_ authTypeState: YooKassaWalletApi.AuthTypeState) {
        self.init(
            specific: authTypeState.specific.plain,
            activeSession: authTypeState.activeSession?.plain,
            canBeIssued: authTypeState.canBeIssued,
            enabled: authTypeState.enabled,
            isSessionRequired: authTypeState.isSessionRequired
        )
    }

    var walletModel: YooKassaWalletApi.AuthTypeState {
        return YooKassaWalletApi.AuthTypeState(self)
    }
}

extension YooKassaWalletApi.AuthTypeState {
    init(_ authTypeState: AuthTypeState) {
        self.init(
            specific: authTypeState.specific.walletModel,
            activeSession: authTypeState.activeSession?.walletModel,
            canBeIssued: authTypeState.canBeIssued,
            enabled: authTypeState.enabled,
            isSessionRequired: authTypeState.isSessionRequired
        )
    }

    var plain: AuthTypeState {
        return AuthTypeState(self)
    }
}
