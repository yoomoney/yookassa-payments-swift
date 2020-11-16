import UIKit
import protocol PassKit.PKPaymentAuthorizationViewControllerDelegate
import SafariServices

class TokenizationRouter: NSObject {

    // MARK: - VIPER module properties

    weak var transitionHandler: TokenizationViewController?
}

// MARK: - TokenizationRouterInput
extension TokenizationRouter: TokenizationRouterInput {
    func presentPaymentMethods(inputData: PaymentMethodsModuleInputData,
                               moduleOutput: PaymentMethodsModuleOutput) {
        if let module = transitionHandler?.modules.last as? PaymentMethodsViewController {
            let (_, moduleInput) = PaymentMethodsAssembly.makeModule(inputData: inputData,
                                                                         moduleOutput: moduleOutput,
                                                                         view: module)
            moduleInput.reloadData()
        } else {
            let paymentMethodsModule = PaymentMethodsAssembly.makeModule(inputData: inputData,
                                                                         moduleOutput: moduleOutput)
            transitionHandler?.show(paymentMethodsModule, sender: self)
        }
    }

    func presentContract(inputData: ContractModuleInputData,
                         moduleOutput: ContractModuleOutput) {
        let viewController = ContractAssembly.makeModule(inputData: inputData,
                                                         moduleOutput: moduleOutput)
        transitionHandler?.show(viewController, sender: self)
    }

    func presentSberbank(inputData: SberbankModuleInputData,
                         moduleOutput: SberbankModuleOutput) {
        let viewController = SberbankAssembly.makeModule(inputData: inputData,
                                                         moduleOutput: moduleOutput)
        transitionHandler?.show(viewController, sender: self)
    }

    func presentBankCardDataInput(inputData: BankCardDataInputModuleInputData,
                                  moduleOutput: BankCardDataInputModuleOutput) {
        let viewController = BankCardDataInputAssembly.makeModule(inputData: inputData,
                                                                  moduleOutput: moduleOutput)
        transitionHandler?.show(viewController, sender: self)
    }

    func presenMaskedBankCardDataInput(inputData: MaskedBankCardDataInputModuleInputData,
                                       moduleOutput: MaskedBankCardDataInputModuleOutput) {
        let viewController = MaskedBankCardDataInputAssembly.makeModule(inputData: inputData,
                                                                        moduleOutput: moduleOutput)
        transitionHandler?.show(viewController, sender: self)
    }

    func presentYamoneyAuthParameters(inputData: YamoneyAuthParametersModuleInputData,
                                      moduleOutput: YamoneyAuthParametersModuleOutput) {
        let viewController = YamoneyAuthParametersAssembly.makeModule(inputData: inputData,
                                                                      moduleOutput: moduleOutput)
        transitionHandler?.show(viewController, sender: self)
    }

    func presentYamoneyAuth(inputData: YamoneyAuthModuleInputData,
                            moduleOutput: YamoneyAuthModuleOutput) {
        let viewController = YamoneyAuthAssembly.makeModule(inputData: inputData,
                                                            moduleOutput: moduleOutput)
        transitionHandler?.show(viewController, sender: self)
    }

    func presentLogoutConfirmation(inputData: LogoutConfirmationModuleInputData,
                                   moduleOutput: LogoutConfirmationModuleOutput) {
        let viewController = LogoutConfirmationAssembly.makeModule(inputData: inputData,
                                                                   moduleOutput: moduleOutput)
        let transitionHandler: UIViewController?
        if let presentedViewController = self.transitionHandler?.presentedViewController {
            transitionHandler = presentedViewController
        } else {
            transitionHandler = self.transitionHandler
        }
        transitionHandler?.present(viewController, animated: true)
    }

    func present3dsModule(inputData: CardSecModuleInputData, moduleOutput: CardSecModuleOutput) {
        let viewController = CardSecAssembly.makeModule(inputData: inputData, moduleOutput: moduleOutput)
        transitionHandler?.show(viewController, sender: self)
    }

    func presentYooMoneyAuth(inputData: YooMoneyAuthModuleInputData,
                             moduleOutput: YooMoneyAuthModuleOutput) {
        if let module = transitionHandler?.modules.last as? PaymentMethodsViewController {
            let yooMoneyAuthModule = YooMoneyAuthAssembly.makeModule(
                inputData: inputData,
                moduleOutput: moduleOutput,
                view: module
            )
            yooMoneyAuthModule.output.setupView()
        } else {
            let yooMoneyAuthModule = YooMoneyAuthAssembly.makeModule(
                inputData: inputData,
                moduleOutput: moduleOutput
            )
            transitionHandler?.show(
                yooMoneyAuthModule,
                sender: self
            )
        }
    }

    func presentApplePay(inputData: ApplePayModuleInputData,
                         moduleOutput: ApplePayModuleOutput) {
        if let viewController = ApplePayAssembly.makeModule(inputData: inputData,
                                                            moduleOutput: moduleOutput) {
            moduleOutput.didPresentApplePayModule()
            transitionHandler?.show(viewController, sender: self)
        } else {
            moduleOutput.didFailPresentApplePayModule()
        }
    }

    func presentError(inputData: ErrorModuleInputData,
                      moduleOutput: ErrorModuleOutput) {
        let viewController = ErrorAssembly.makeModule(inputData: inputData,
                                                      moduleOutput: moduleOutput)
        transitionHandler?.show(viewController, sender: self)
    }

    func presentTermsOfServiceModule(_ url: URL) {
        if #available(iOS 9, *) {
            let viewController = SFSafariViewController(url: url)
            viewController.modalPresentationStyle = .overFullScreen
            transitionHandler?.present(viewController, animated: true)
        } else {
            let presenter = WebBrowserPresenter()
            let interactor = WebBrowserInteractor(url: url)
            interactor.output = presenter
            let viewController = WebBrowserAssembly.makeModule(
                presenter: presenter,
                interactor: interactor
            )
            let navigationController = UINavigationController(rootViewController: viewController)
            transitionHandler?.present(navigationController, animated: true)
        }
    }

    func presentApplePayContract(inputData: ApplePayContractModuleInputData,
                                 moduleOutput: ApplePayContractModuleOutput) {
        let viewController = ApplePayContractAssembly.makeModule(inputData: inputData,
                                                                 moduleOutput: moduleOutput)
        transitionHandler?.show(viewController, sender: self)
    }

    func presentSavePaymentMethodInfo(inputData: SavePaymentMethodInfoModuleInputData) {
        let viewController = SavePaymentMethodInfoAssembly.makeModule(inputData: inputData)
        let navigationController = UINavigationController(rootViewController: viewController)
        transitionHandler?.present(navigationController, animated: true, completion: nil)
    }
}

extension TokenizationRouter: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        let presentationController = DimmingPresentationController(presentedViewController: presented,
                                                                   presenting: presenting)
        return presentationController
    }
}
