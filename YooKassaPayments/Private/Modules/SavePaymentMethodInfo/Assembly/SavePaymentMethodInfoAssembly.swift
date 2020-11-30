enum SavePaymentMethodInfoAssembly {
    static func makeModule(
        inputData: SavePaymentMethodInfoModuleInputData
    ) -> UIViewController {
        let view = SavePaymentMethodInfoViewController()

        let presenter = SavePaymentMethodInfoPresenter(
            inputData: inputData
        )

        view.output = presenter

        presenter.view = view

        return view
    }
}
