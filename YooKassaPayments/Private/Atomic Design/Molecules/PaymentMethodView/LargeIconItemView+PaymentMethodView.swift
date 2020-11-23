extension LargeIconItemView: PaymentMethodViewInput {
    func setPaymentMethodViewModel(_ paymentMethodViewModel: PaymentMethodViewModel) {
        image = paymentMethodViewModel.image
        actionButtonTitle = paymentMethodViewModel.name

        guard let balanceString = paymentMethodViewModel.balanceText else {
            assertionFailure("Couldn't create balance string")
            return
        }
        title = balanceString
    }
}
