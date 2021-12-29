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
    private let termsOfService: NSAttributedString
    private let isBackBarButtonHidden: Bool
    private let isSafeDeal: Bool
    private let clientSavePaymentMethod: SavePaymentMethod

    private var recurrencySectionSwitchValue: Bool?
    private let isSavePaymentMethodAllowed: Bool
    private let config: Config

    init(
        shopName: String,
        purchaseDescription: String,
        priceViewModel: PriceViewModel,
        feeViewModel: PriceViewModel?,
        termsOfService: NSAttributedString,
        isBackBarButtonHidden: Bool,
        isSafeDeal: Bool,
        clientSavePaymentMethod: SavePaymentMethod,
        isSavePaymentMethodAllowed: Bool,
        config: Config
    ) {
        self.shopName = shopName
        self.purchaseDescription = purchaseDescription
        self.priceViewModel = priceViewModel
        self.feeViewModel = feeViewModel
        self.termsOfService = termsOfService
        self.isBackBarButtonHidden = isBackBarButtonHidden
        self.isSafeDeal = isSafeDeal
        self.clientSavePaymentMethod = clientSavePaymentMethod
        self.isSavePaymentMethodAllowed = isSavePaymentMethodAllowed
        self.config = config
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

        var section: PaymentRecurrencyAndDataSavingSection?
        if isSavePaymentMethodAllowed {
            switch clientSavePaymentMethod {
            case .userSelects:
                section = PaymentRecurrencyAndDataSavingSectionFactory.make(
                    mode: .allowRecurring,
                    texts: config.savePaymentMethodOptionTexts,
                    output: self
                )
                recurrencySectionSwitchValue = section?.switchValue
            case .on:
                section = PaymentRecurrencyAndDataSavingSectionFactory.make(
                    mode: .requiredRecurring,
                    texts: config.savePaymentMethodOptionTexts,
                    output: self
                )
                recurrencySectionSwitchValue = true
            case .off:
                section = nil
            }
        }

        let viewModel = SberpayViewModel(
            shopName: shopName,
            description: purchaseDescription,
            priceValue: priceValue,
            feeValue: feeValue,
            termsOfService: termsOfService,
            safeDealText: isSafeDeal ? PaymentMethodResources.Localized.safeDealInfoLink : nil,
            recurrencyAndDataSavingSection: section,
            paymentOptionTitle: config.paymentMethods.first { $0.kind == .sberbank }?.title
        )
        view.setupViewModel(viewModel)

        view.setBackBarButtonHidden(isBackBarButtonHidden)

        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            self.interactor.track(event:
                .screenPaymentContract(
                    scheme: .sberpay,
                    currentAuthType: self.interactor.analyticsAuthType()
                )
            )
        }
    }

    func didTapActionButton() {
        guard let view = view else { return }
        view.showActivity()
        DispatchQueue.global().async { [weak self] in
            guard let self = self, let interactor = self.interactor else { return }
            interactor.tokenizeSberpay(savePaymentMethod: self.recurrencySectionSwitchValue ?? false)
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
    func didTokenize(_ data: Tokens) {
        interactor.track(event:
            .actionTokenize(
                scheme: .sberpay,
                currentAuthType: interactor.analyticsAuthType()
            )
        )
        moduleOutput?.sberpayModule(self, didTokenize: data, paymentMethodType: .sberbank)

        DispatchQueue.main.async { [weak self] in
            guard let view = self?.view else { return }
            view.hideActivity()
        }
    }

    func didFailTokenize(_ error: Error) {
        interactor.track(
            event: .screenErrorContract(scheme: .sberpay, currentAuthType: interactor.analyticsAuthType())
        )

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
            guard let self = self, let interactor = self.interactor else { return }
            interactor.track(
                event: .actionTryTokenize(scheme: .sberpay, currentAuthType: interactor.analyticsAuthType())
            )
            interactor.tokenizeSberpay(savePaymentMethod: self.recurrencySectionSwitchValue ?? false)
        }
    }
}

// MARK: - PaymentRecurrencyAndDataSavingSectionOutput

extension SberpayPresenter: PaymentRecurrencyAndDataSavingSectionOutput {
    func didChangeSwitchValue(newValue: Bool, mode: PaymentRecurrencyAndDataSavingSection.Mode) {
        recurrencySectionSwitchValue = newValue
    }
    func didTapInfoLink(mode: PaymentRecurrencyAndDataSavingSection.Mode) {
        switch mode {
        case .allowRecurring, .requiredRecurring:
            router.presentSafeDealInfo(
                title: htmlOut(source: config.savePaymentMethodOptionTexts.screenRecurrentOnBindOffTitle),
                body: htmlOut(source: config.savePaymentMethodOptionTexts.screenRecurrentOnBindOffText)
            )
        case .savePaymentData, .requiredSaveData:
            router.presentSafeDealInfo(
                title: htmlOut(source: config.savePaymentMethodOptionTexts.screenRecurrentOffBindOnTitle),
                body: htmlOut(source: config.savePaymentMethodOptionTexts.screenRecurrentOffBindOnText)
            )
        case .allowRecurringAndSaveData, .requiredRecurringAndSaveData:
            router.presentSafeDealInfo(
                title: htmlOut(source: config.savePaymentMethodOptionTexts.screenRecurrentOnBindOnTitle),
                body: htmlOut(source: config.savePaymentMethodOptionTexts.screenRecurrentOnBindOnText)
            )
        default:
        break
        }
    }

    /// Convert <br> -> \n and other html text formatting to native `String`
    private func htmlOut(source: String) -> String {
        guard let data = source.data(using: .utf16) else { return source }
        do {
            let html = try NSAttributedString(
                data: data,
                options: [.documentType: NSAttributedString.DocumentType.html],
                documentAttributes: nil
            )
            return html.string
        } catch {
            return source
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
