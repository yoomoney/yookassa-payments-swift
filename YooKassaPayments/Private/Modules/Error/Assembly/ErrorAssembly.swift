import UIKit.UIViewController

enum ErrorAssembly {
    static func makeModule(
        inputData: ErrorModuleInputData,
        moduleOutput: ErrorModuleOutput
    ) -> UIViewController {
        let viewController = ErrorViewController()
        let presenter = ErrorPresenter(inputData: inputData)

        presenter.view = viewController
        presenter.moduleOutput = moduleOutput

        viewController.output = presenter

        return viewController
    }
}
