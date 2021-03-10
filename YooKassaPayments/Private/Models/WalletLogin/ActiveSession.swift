import YooKassaWalletApi

/// Description of the active session
struct ActiveSession {

    /// The total number of attempts
    let attemptsCount: Int

    /// The remaining number of code entry attempts
    let attemptsLeft: Int

    init(
        attemptsCount: Int,
        attemptsLeft: Int
    ) {
        self.attemptsCount = attemptsCount
        self.attemptsLeft = attemptsLeft
    }
}

// MARK: - ActiveSession converter

extension ActiveSession {
    init(_ activeSession: YooKassaWalletApi.AuthTypeState.ActiveSession) {
        self.init(
            attemptsCount: activeSession.attemptsCount,
            attemptsLeft: activeSession.attemptsLeft
        )
    }

    var walletModel: YooKassaWalletApi.AuthTypeState.ActiveSession {
        return YooKassaWalletApi.AuthTypeState.ActiveSession(self)
    }
}

extension YooKassaWalletApi.AuthTypeState.ActiveSession {
    init(_ activeSession: ActiveSession) {
        self.init(
            attemptsCount: activeSession.attemptsCount,
            attemptsLeft: activeSession.attemptsLeft
        )
    }

    var plain: ActiveSession {
        return ActiveSession(self)
    }
}
