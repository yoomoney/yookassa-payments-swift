extension IconItemView: PaymentMethodViewInput {
    func setPaymentMethodViewModel(_ paymentMethodViewModel: PaymentMethodViewModel) {
        title = paymentMethodViewModel.name
        icon = paymentMethodViewModel.image
    }
}
