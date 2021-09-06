import UIKit

final class SberpayPresenter {

    // MARK: - VIPER

    weak var moduleOutput: SberpayModuleOutput?
    weak var view: SberpayViewInput?
    var interactor: SberpayInteractorInput!
    var router: SberpayRouterInput!

    // MARK: - Init

    private let shopName: String
    private let purchaseDescription: String
    private let priceViewModel: PriceViewModel
    private let feeViewModel: PriceViewModel?
    private let termsOfService: TermsOfService
    private let isBackBarButtonHidden: Bool
    private let isSafeDeal: Bool

    init(
        shopName: String,
        purchaseDescription: String,
        priceViewModel: PriceViewModel,
        feeViewModel: PriceViewModel?,
        termsOfService: TermsOfService,
        isBackBarButtonHidden: Bool,
        isSafeDeal: Bool
    ) {
        self.shopName = shopName
        self.purchaseDescription = purchaseDescription
        self.priceViewModel = priceViewModel
        self.feeViewModel = feeViewModel
        self.termsOfService = termsOfService
        self.isBackBarButtonHidden = isBackBarButtonHidden
        self.isSafeDeal = isSafeDeal
    }
}

// MARK: - SberpayViewOutput

extension SberpayPresenter: SberpayViewOutput {
    func setupView() {
        guard let view = view else { return }
        let priceValue = makePrice(priceViewModel)

        var feeValue: String?
        if let feeViewModel = feeViewModel {
            feeValue = "\(CommonLocalized.Contract.fee) " + makePrice(feeViewModel)
        }

        let termsOfServiceValue = makeTermsOfService(
            termsOfService,
            font: UIFont.dynamicCaption2,
            foregroundColor: UIColor.AdaptiveColors.secondary
        )
        let viewModel = SberpayViewModel(
            shopName: shopName,
            description: purchaseDescription,
            priceValue: priceValue,
            feeValue: feeValue,
            termsOfService: termsOfServiceValue,
            safeDealText: isSafeDeal ? PaymentMethodResources.Localized.safeDealInfoLink : nil
        )
        view.setupViewModel(viewModel)

        view.setBackBarButtonHidden(isBackBarButtonHidden)

        DispatchQueue.global().async { [weak self] in
            guard let self = self,
                  let interactor = self.interactor else { return }
            let (authType, _) = interactor.makeTypeAnalyticsParameters()
            let event: AnalyticsEvent = .screenPaymentContract(
                authType: authType,
                scheme: .sberpay,
                sdkVersion: Bundle.frameworkVersion
            )
            interactor.trackEvent(event)
        }
    }

    func didTapActionButton() {
        guard let view = view else { return }
        view.showActivity()
        DispatchQueue.global().async { [weak self] in
            guard let self = self,
                  let interactor = self.interactor else { return }
            interactor.tokenizeSberpay()
        }
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
}

// MARK: - SberpayInteractorOutput

extension SberpayPresenter: SberpayInteractorOutput {
    func didTokenize(
        _ data: Tokens
    ) {
        let analyticsParameters = interactor.makeTypeAnalyticsParameters()
        let event: AnalyticsEvent = .actionTokenize(
            scheme: .sberpay,
            authType: analyticsParameters.authType,
            tokenType: analyticsParameters.tokenType,
            sdkVersion: Bundle.frameworkVersion
        )
        interactor.trackEvent(event)
        moduleOutput?.sberpayModule(
            self,
            didTokenize: data,
            paymentMethodType: .sberbank
        )

        DispatchQueue.main.async { [weak self] in
            guard let view = self?.view else { return }
            view.hideActivity()
        }
    }

    func didFailTokenize(
        _ error: Error
    ) {
        let parameters = interactor.makeTypeAnalyticsParameters()
        let event: AnalyticsEvent = .screenError(
            authType: parameters.authType,
            scheme: .smsSbol,
            sdkVersion: Bundle.frameworkVersion
        )
        interactor.trackEvent(event)

        let message = makeMessage(error)

        DispatchQueue.main.async { [weak self] in
            guard let view = self?.view else { return }
            view.hideActivity()
            view.showPlaceholder(with: message)
        }
    }
}

// MARK: - ActionTitleTextDialogDelegate

extension SberpayPresenter: ActionTitleTextDialogDelegate {
    func didPressButton(
        in actionTitleTextDialog: ActionTitleTextDialog
    ) {
        guard let view = view else { return }
        view.hidePlaceholder()
        view.showActivity()
        DispatchQueue.global().async { [weak self] in
            guard let self = self,
                  let interactor = self.interactor else { return }
            interactor.tokenizeSberpay()
        }
    }
}

// MARK: - SberpayModuleInput

extension SberpayPresenter: SberpayModuleInput {}

// MARK: - Private helpers

private extension SberpayPresenter {
    func makePrice(
        _ priceViewModel: PriceViewModel
    ) -> String {
        priceViewModel.integerPart
            + priceViewModel.decimalSeparator
            + priceViewModel.fractionalPart
            + priceViewModel.currency
    }

    func makeTermsOfService(
        _ terms: TermsOfService,
        font: UIFont,
        foregroundColor: UIColor
    ) -> NSMutableAttributedString {
        let attributedText: NSMutableAttributedString

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: foregroundColor,
        ]
        attributedText = NSMutableAttributedString(
            string: "\(terms.text) ",
            attributes: attributes
        )

        let linkAttributedText = NSMutableAttributedString(
            string: terms.hyperlink,
            attributes: attributes
        )
        let linkRange = NSRange(location: 0, length: terms.hyperlink.count)
        linkAttributedText.addAttribute(.link, value: terms.url, range: linkRange)
        attributedText.append(linkAttributedText)

        return attributedText
    }

    func makeMessage(
        _ error: Error
    ) -> String {
        let message: String

        switch error {
        case let error as PresentableError:
            message = error.message
        default:
            message = CommonLocalized.Error.unknown
        }

        return message
    }
}
