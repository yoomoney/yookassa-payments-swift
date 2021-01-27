extension LargeIconItemView: PaymentMethodViewInput {
    func setPaymentMethodViewModel(
        _ paymentMethodViewModel: PaymentMethodViewModel
    ) {
        self.image = paymentMethodViewModel.image
        self.actionButtonTitle = paymentMethodViewModel.title

        guard let subtitle = paymentMethodViewModel.subtitle else {
            assertionFailure("Couldn't create balance string")
            return
        }
        self.title = subtitle
    }
}
