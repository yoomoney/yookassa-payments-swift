extension IconButtonItemView: PaymentMethodViewInput {
    func setPaymentMethodViewModel(_ paymentMethodViewModel: PaymentMethodViewModel) {
        title = paymentMethodViewModel.name
        image = paymentMethodViewModel.image
        buttonTitle = paymentMethodViewModel.change
    }
}
