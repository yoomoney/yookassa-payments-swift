enum WalletLoginResponse {
    case authorized(CheckoutTokenIssueExecute)
    case notAuthorized(authTypeState: AuthTypeState, processId: String, authContextId: String)
}
