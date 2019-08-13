protocol PaymentMethodViewInput: class {
    func setPaymentMethodViewModel(_ paymentMethodViewModel: PaymentMethodViewModel)
}

protocol PaymentMethodViewOutput: class {
    func didPressChangePaymentMethod(in paymentMethodViewInput: PaymentMethodViewInput)
}
