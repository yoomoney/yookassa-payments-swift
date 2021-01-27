extension LargeIconButtonItemView: PaymentMethodViewInput {
    func setPaymentMethodViewModel(
        _ paymentMethodViewModel: PaymentMethodViewModel
    ) {
        self.image = paymentMethodViewModel.image
        self.title = paymentMethodViewModel.title
        self.rightButtonTitle = paymentMethodViewModel.change
        guard let subtitle = paymentMethodViewModel.subtitle else {
            assertionFailure("Couldn't create balance string")
            return
        }
        self.subtitle = subtitle
    }
}
