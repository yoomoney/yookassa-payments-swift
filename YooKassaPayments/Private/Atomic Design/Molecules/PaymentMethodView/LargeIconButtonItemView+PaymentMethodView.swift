extension LargeIconButtonItemView: PaymentMethodViewInput {
    func setPaymentMethodViewModel(_ paymentMethodViewModel: PaymentMethodViewModel) {
        image = paymentMethodViewModel.image
        leftButtonTitle = paymentMethodViewModel.name
        rightButtonTitle = paymentMethodViewModel.change
        guard let balanceString = paymentMethodViewModel.balanceText else {
            assertionFailure("Couldn't create balance string")
            return
        }
        title = balanceString
    }
}
