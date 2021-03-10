import YooKassaWalletApi

struct CheckoutTokenIssueExecute: Equatable {

    /// Main payment token
    let accessToken: String

    init(accessToken: String) {
        self.accessToken = accessToken
    }
}

// MARK: - CheckoutTokenIssueExecute converter

extension CheckoutTokenIssueExecute {
    init(_ checkoutTokenIssueExecute: YooKassaWalletApi.CheckoutTokenIssueExecute) {
        self.init(
            accessToken: checkoutTokenIssueExecute.accessToken
        )
    }

    var walletModel: YooKassaWalletApi.CheckoutTokenIssueExecute {
        return YooKassaWalletApi.CheckoutTokenIssueExecute(self)
    }
}

extension YooKassaWalletApi.CheckoutTokenIssueExecute {
    init(_ checkoutTokenIssueExecute: CheckoutTokenIssueExecute) {
        self.init(
            accessToken: checkoutTokenIssueExecute.accessToken
        )
    }

    var plain: CheckoutTokenIssueExecute {
        return CheckoutTokenIssueExecute(self)
    }
}
