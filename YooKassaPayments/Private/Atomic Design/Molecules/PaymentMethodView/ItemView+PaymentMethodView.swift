extension IconItemView: PaymentMethodViewInput {
    func setPaymentMethodViewModel(
        _ paymentMethodViewModel: PaymentMethodViewModel
    ) {
        self.icon = paymentMethodViewModel.image
        self.title = paymentMethodViewModel.title
    }
}
