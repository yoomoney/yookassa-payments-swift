enum RecurringInfoAssembly {
    static func makeModule(
        inputData: RecurringInfoModuleInputData
    ) -> UIViewController {
        let view = RecurringInfoViewController()

        let presenter = RecurringInfoPresenter(
            inputData: inputData
        )

        view.output = presenter

        presenter.view = view

        return view
    }
}
