import PassKit
import YooKassaPaymentsApi

final class ApplePayContractPresenter: NSObject {
    
    private enum ApplePayState {
        case idle
        case success
        case cancel
    }

    // MARK: - VIPER

    var interactor: ApplePayContractInteractorInput!
    var router: ApplePayContractRouterInput!
    
    weak var view: ApplePayContractViewInput?
    weak var moduleOutput: ApplePayContractModuleOutput?

    // MARK: - Init data

    private let shopName: String
    private let purchaseDescription: String
    private let price: PriceViewModel
    private let fee: PriceViewModel?
    private let paymentOption: PaymentOption
    private let termsOfService: TermsOfService
    private let merchantIdentifier: String?
    private let savePaymentMethodViewModel: SavePaymentMethodViewModel?
    private var initialSavePaymentMethod: Bool

    // MARK: - Init

    init(
        shopName: String,
        purchaseDescription: String,
        price: PriceViewModel,
        fee: PriceViewModel?,
        paymentOption: PaymentOption,
        termsOfService: TermsOfService,
        merchantIdentifier: String?,
        savePaymentMethodViewModel: SavePaymentMethodViewModel?,
        initialSavePaymentMethod: Bool
    ) {
        self.shopName = shopName
        self.purchaseDescription = purchaseDescription
        self.price = price
        self.fee = fee
        self.paymentOption = paymentOption
        self.termsOfService = termsOfService
        self.merchantIdentifier = merchantIdentifier
        self.savePaymentMethodViewModel = savePaymentMethodViewModel
        self.initialSavePaymentMethod = initialSavePaymentMethod
    }
    
    // MARK: - Stored properties
    
    private var applePayCompletion: ((PKPaymentAuthorizationStatus) -> Void)?
    private var applePayState: ApplePayState = .idle
}

// MARK: - ContractViewOutput

extension ApplePayContractPresenter: ApplePayContractViewOutput {
    func setupView() {
        guard let view = view else { return }
        
        let viewModel = ApplePayContractViewModel(
            shopName: shopName,
            description: purchaseDescription,
            price: price,
            fee: fee,
            terms: termsOfService
        )
        
        view.setupViewModel(viewModel)
        
        if let savePaymentMethodViewModel = savePaymentMethodViewModel {
            view.setSavePaymentMethodViewModel(
                savePaymentMethodViewModel
            )
        }
    }
    
    func didTapActionButton() {
        let moduleInputData = ApplePayModuleInputData(
            merchantIdentifier: merchantIdentifier,
            amount: MonetaryAmountFactory.makeAmount(paymentOption.charge),
            shopName: shopName,
            purchaseDescription: purchaseDescription,
            supportedNetworks: ApplePayConstants.paymentNetworks,
            fee: paymentOption.fee?.plain
        )
        router.presentApplePay(
            inputData: moduleInputData,
            moduleOutput: self
        )
    }
    
    func didTapTermsOfService(_ url: URL) {
        router.presentTermsOfServiceModule(url)
    }
    
    func didTapOnSavePaymentMethod() {
        let savePaymentMethodModuleinputData = SavePaymentMethodInfoModuleInputData(
            headerValue: §SavePaymentMethodInfoLocalization.Wallet.header,
            bodyValue: §SavePaymentMethodInfoLocalization.Wallet.body
        )
        router.presentSavePaymentMethodInfo(
            inputData: savePaymentMethodModuleinputData
        )
    }
    
    func didChangeSavePaymentMethodState(
        _ state: Bool
    ) {
        initialSavePaymentMethod = state
    }
    
    private func trackScreenErrorAnalytics(
        scheme: AnalyticsEvent.TokenizeScheme?
    ) {
        DispatchQueue.global().async { [weak self] in
            guard let interactor = self?.interactor else { return }
            let (authType, _) = interactor.makeTypeAnalyticsParameters()
            interactor.trackEvent(.screenError(authType: authType, scheme: scheme))
        }
    }
    
    private func trackScreenPaymentAnalytics(
        scheme: AnalyticsEvent.TokenizeScheme
    ) {
        DispatchQueue.global().async { [weak self] in
            guard let interactor = self?.interactor else { return }
            let (authType, _) = interactor.makeTypeAnalyticsParameters()
            interactor.trackEvent(.screenPaymentContract(authType: authType, scheme: scheme))
        }
    }
}

// MARK: - ContractInteractorOutput

extension ApplePayContractPresenter: ApplePayContractInteractorOutput {
    func didTokenize(
        _ token: Tokens
    ) {
        guard applePayState == .success else {
            return
        }
        
        applePayCompletion?(.success)
        
        DispatchQueue.main.asyncAfter(
            deadline: .now() + Constants.dismissTimeout
        ) { [weak self] in
            guard let self = self else { return }
            self.router.closeApplePay() {
                self.moduleOutput?.tokenizationModule(
                    self,
                    didTokenize: token,
                    paymentMethodType: .applePay
                )
            }
        }
    }
    
    func failTokenize(
        _ error: Error
    ) {
        guard applePayState == .success else {
            return
        }
        
        trackScreenErrorAnalytics(scheme: .applePay)
        applePayCompletion?(.failure)
        
        DispatchQueue.main.asyncAfter(
            deadline: .now() + Constants.dismissTimeout
        ) { [weak self] in
            guard let self = self else { return }
            self.router.closeApplePay() {
                self.view?.presentError(with: §Localized.Error.failTokenizeData)
            }
        }
    }
}

// MARK: - ApplePayModuleOutput

extension ApplePayContractPresenter: ApplePayModuleOutput {
    func didPresentApplePayModule() {
        applePayState = .idle
        trackScreenPaymentAnalytics(scheme: .applePay)
    }

    func didFailPresentApplePayModule() {
        applePayState = .idle
        trackScreenErrorAnalytics(scheme: .applePay)
        
        DispatchQueue.main.async { [weak self] in
            guard let view = self?.view else { return }
            view.presentError(with: §Localized.applePayUnavailableTitle)
        }
    }

    @available(iOS 11.0, *)
    func paymentAuthorizationViewController(
        _ controller: PKPaymentAuthorizationViewController,
        didAuthorizePayment payment: PKPayment,
        handler completion: @escaping (PKPaymentAuthorizationResult) -> Void
    ) {
        paymentAuthorizationViewController(
            controller,
            didAuthorizePayment: payment
        ) { status in
            completion(PKPaymentAuthorizationResult(status: status, errors: nil))
        }
    }

    func paymentAuthorizationViewController(
        _ controller: PKPaymentAuthorizationViewController,
        didAuthorizePayment payment: PKPayment,
        completion: @escaping (PKPaymentAuthorizationStatus) -> Void
    ) {
        guard applePayState != .cancel else { return }
        
        applePayState = .success
        applePayCompletion = completion
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            self.interactor.tokenize(
                paymentData: payment.token.paymentData.base64EncodedString(),
                savePaymentMethod: self.initialSavePaymentMethod,
                amount: self.paymentOption.charge.plain
            )
        }
    }

    func paymentAuthorizationViewControllerDidFinish(
        _ controller: PKPaymentAuthorizationViewController
    ) {
        router.closeApplePay(completion: nil)
        applePayState = .cancel
    }
}

// MARK: - ApplePayContractModuleInput

extension ApplePayContractPresenter: ApplePayContractModuleInput {}

// MARK: - Constants

private extension ApplePayContractPresenter {
    enum Constants {
        static let dismissTimeout: TimeInterval = 0.5
    }
}

// MARK: - Localized

private extension ApplePayContractPresenter {
    enum Localized: String {
        case applePayUnavailableTitle = "ApplePayUnavailable.title"
        
        enum Error: String {
            case failTokenizeData = "Error.ApplePayStrategy.failTokenizeData"
        }
    }
}
