extension IconButtonItemView: PaymentMethodViewInput {
    func setPaymentMethodViewModel(
        _ paymentMethodViewModel: PaymentMethodViewModel
    ) {
        self.image = paymentMethodViewModel.image
        self.title = paymentMethodViewModel.title
        self.buttonTitle = paymentMethodViewModel.change
    }
}
