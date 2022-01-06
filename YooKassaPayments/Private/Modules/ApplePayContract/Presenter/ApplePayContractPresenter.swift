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
    private let termsOfService: NSAttributedString
    private let merchantIdentifier: String?
    private let savePaymentMethodViewModel: SavePaymentMethodViewModel?
    private var initialSavePaymentMethod: Bool
    private let isBackBarButtonHidden: Bool
    private let isSafeDeal: Bool
    private let paymentOptionTitle: String?

    // MARK: - Init

    init(
        shopName: String,
        purchaseDescription: String,
        price: PriceViewModel,
        fee: PriceViewModel?,
        paymentOption: PaymentOption,
        termsOfService: NSAttributedString,
        merchantIdentifier: String?,
        savePaymentMethodViewModel: SavePaymentMethodViewModel?,
        initialSavePaymentMethod: Bool,
        isBackBarButtonHidden: Bool,
        isSafeDeal: Bool,
        paymentOptionTitle: String?
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
        self.isBackBarButtonHidden = isBackBarButtonHidden
        self.isSafeDeal = isSafeDeal
        self.paymentOptionTitle = paymentOptionTitle
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
            terms: termsOfService,
            safeDealText: isSafeDeal ? PaymentMethodResources.Localized.safeDealInfoLink : nil,
            paymentOptionTitle: paymentOptionTitle
        )

        view.setupViewModel(viewModel)

        if let savePaymentMethodViewModel = savePaymentMethodViewModel {
            view.setSavePaymentMethodViewModel(
                savePaymentMethodViewModel
            )
        }

        view.setBackBarButtonHidden(isBackBarButtonHidden)
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

    func didTapSafeDealInfo(_ url: URL) {
        router.presentSafeDealInfo(
            title: PaymentMethodResources.Localized.safeDealInfoTitle,
            body: PaymentMethodResources.Localized.safeDealInfoBody
        )
    }

    func didTapOnSavePaymentMethod() {
        let savePaymentMethodModuleinputData = SavePaymentMethodInfoModuleInputData(
            headerValue: SavePaymentMethodInfoLocalization.BankCard.header,
            bodyValue: SavePaymentMethodInfoLocalization.BankCard.body
        )
        router.presentSavePaymentMethodInfo(
            inputData: savePaymentMethodModuleinputData
        )
    }

    func didChangeSavePaymentMethodState(_ state: Bool) {
        initialSavePaymentMethod = state
    }

    private func trackScreenErrorAnalytics(scheme: AnalyticsEvent.TokenizeScheme?, savePaymentMethod: Bool?) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            self.interactor.track(event:
                .screenError(
                    scheme: .applePay,
                    currentAuthType: self.interactor.analyticsAuthType()
                )
            )
        }
    }

    private func trackScreenPaymentAnalytics(scheme: AnalyticsEvent.TokenizeScheme) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            self.interactor.track(event:
                .screenPaymentContract(
                    scheme: .applePay,
                    currentAuthType: self.interactor.analyticsAuthType()
                )
            )
        }
    }
}

// MARK: - ContractInteractorOutput

extension ApplePayContractPresenter: ApplePayContractInteractorOutput {
    func didTokenize(_ token: Tokens) {
        guard applePayState == .success else { return }

        applePayCompletion?(.success)
        interactor.track(event:
            .actionTokenize(
                scheme: .applePay,
                currentAuthType: interactor.analyticsAuthType()
            )
        )
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.dismissTimeout) { [weak self] in
            guard let self = self else { return }
            self.router.closeApplePay {
                self.moduleOutput?.tokenizationModule(
                    self,
                    didTokenize: token,
                    paymentMethodType: .applePay
                )
            }
        }
    }

    func failTokenize(_ error: Error) {
        guard applePayState == .success else { return }

        trackScreenErrorAnalytics(scheme: .applePay, savePaymentMethod: paymentOption.savePaymentMethod == .allowed)
        applePayCompletion?(.failure)
        interactor.track(
            event: .screenErrorContract(scheme: .applePay, currentAuthType: interactor.analyticsAuthType())
        )

        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.dismissTimeout) { [weak self] in
            guard let self = self else { return }
            self.router.closeApplePay {
                self.view?.presentError(with: CommonLocalized.ApplePay.failTokenizeData)
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
        interactor.track(
            event: .screenErrorContract(scheme: .applePay, currentAuthType: interactor.analyticsAuthType())
        )

        DispatchQueue.main.async { [weak self] in
            guard let view = self?.view else { return }
            view.presentError(with: CommonLocalized.ApplePay.applePayUnavailableTitle)
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

        interactor.track(event: .actionTryTokenize(scheme: .applePay, currentAuthType: interactor.analyticsAuthType()))

        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }

            self.interactor.tokenize(
                paymentData: payment.token.paymentData.base64EncodedString(),
                savePaymentMethod: self.initialSavePaymentMethod,
                amount: self.paymentOption.charge.plain
            )
        }
    }

    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
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
