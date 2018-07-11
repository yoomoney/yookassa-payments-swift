import UIKit

enum SimpleIdentificationAssembly {

    static func makeModule(inputData: SimpleIdentificationInputData,
                           moduleOutput: SimpleIdentificationModuleOutput?) -> UIViewController {

        let identificationService = IdentificationProcessingAssembly.makeService()
        let authorizationService = AuthorizationProcessingAssembly.makeService(testModeSettings: nil)

        let view = SimpleIdentificationViewController()
        let presenter = SimpleIdentificationPresenter()
        let interactor = SimpleIdentificationInteractor(identificationService: identificationService,
                                                        authorizationService: authorizationService,
                                                        merchantToken: inputData.merchantToken,
                                                        language: inputData.language)
        view.output = presenter

        presenter.view = view
        presenter.interactor = interactor
        presenter.moduleOutput = moduleOutput

        interactor.output = presenter

        return view
    }
}
