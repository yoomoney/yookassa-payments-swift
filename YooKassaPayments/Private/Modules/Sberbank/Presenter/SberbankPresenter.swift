import UIKit

final class SberbankPresenter {

    // MARK: - VIPER

    weak var moduleOutput: SberbankModuleOutput?
    weak var view: SberbankViewInput?
    var interactor: SberbankInteractorInput!
    var router: SberbankRouterInput!

    // MARK: - Module inputs

    weak var phoneNumberModuleInput: PhoneNumberInputModuleInput?

    // MARK: - Init

    private let shopName: String
    private let purchaseDescription: String
    private let priceViewModel: PriceViewModel
    private let feeViewModel: PriceViewModel?
    private let termsOfService: NSAttributedString
    private let userPhoneNumber: String?
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
        userPhoneNumber: String?,
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
        self.userPhoneNumber = userPhoneNumber
        self.isBackBarButtonHidden = isBackBarButtonHidden
        self.isSafeDeal = isSafeDeal
        self.clientSavePaymentMethod = clientSavePaymentMethod
        self.isSavePaymentMethodAllowed = isSavePaymentMethodAllowed
        self.config = config
    }

    // MARK: - Stored properties

    private var phoneNumber: String = ""
}

// MARK: - SberbankViewOutput

extension SberbankPresenter: SberbankViewOutput {
    func setupView() {
        guard let view = view else { return }
        let priceValue = makePrice(priceViewModel)

        var feeValue: String?
        if let feeViewModel = feeViewModel {
            feeValue = "\(CommonLocalized.Contract.fee) " + makePrice(feeViewModel)
        }

        let termsOfServiceValue = termsOfService

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

        let viewModel = SberbankViewModel(
            shopName: shopName,
            description: purchaseDescription,
            priceValue: priceValue,
            feeValue: feeValue,
            termsOfService: termsOfServiceValue,
            safeDealText: isSafeDeal ? PaymentMethodResources.Localized.safeDealInfoLink : nil,
            recurrencyAndDataSavingSection: section,
            paymentOptionTitle: config.paymentMethods.first { $0.kind == .sberbank }?.title
        )
        view.setViewModel(viewModel)

        let title = Localized.phoneInputTitle
        phoneNumberModuleInput?.setTitle(title.uppercased())
        phoneNumberModuleInput?.setPlaceholder(Localized.phoneInputPlaceholder)
        phoneNumberModuleInput?.setSubtitle(Localized.phoneInputBottomHint)

        if let userPhoneNumber = userPhoneNumber {
            phoneNumberModuleInput?.setValue(userPhoneNumber)
        }

        view.setBackBarButtonHidden(isBackBarButtonHidden)

        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            self.interactor.track(event:
                .screenPaymentContract(
                    scheme: .smsSbol,
                    currentAuthType: self.interactor.analyticsAuthType()
                )
            )
        }
    }

    func didPressSubmitButton() {
        guard let view = view else { return }
        view.endEditing(true)
        view.showActivity()
        DispatchQueue.global().async { [weak self] in
            guard let self = self,
                  let interactor = self.interactor else { return }
            interactor.tokenizeSberbank(
                phoneNumber: self.phoneNumber,
                savePaymentMethod: self.recurrencySectionSwitchValue ?? false
            )
        }
    }

    func didPressTermsOfService(_ url: URL) {
        router.presentTermsOfServiceModule(url)
    }

    func didTapSafeDealInfo(_ url: URL) {
        router.presentSafeDealInfo(
            title: PaymentMethodResources.Localized.safeDealInfoTitle,
            body: PaymentMethodResources.Localized.safeDealInfoBody
        )
    }
}

// MARK: - SberbankInteractorOutput

extension SberbankPresenter: SberbankInteractorOutput {
    func didTokenize(_ data: Tokens) {
        interactor.track(event:
            .actionTokenize(
                scheme: .smsSbol,
                currentAuthType: interactor.analyticsAuthType()
            )
        )
        moduleOutput?.sberbankModule(self, didTokenize: data, paymentMethodType: .sberbank)
    }

    func didFailTokenize(_ error: Error) {
        interactor.track(
            event: .screenErrorContract(scheme: .smsSbol, currentAuthType: interactor.analyticsAuthType())
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

extension SberbankPresenter: ActionTitleTextDialogDelegate {
    func didPressButton(
        in actionTitleTextDialog: ActionTitleTextDialog
    ) {
        guard let view = view else { return }
        view.hidePlaceholder()
        view.showActivity()
        DispatchQueue.global().async { [weak self] in
            guard let self = self, let interactor = self.interactor else { return }
            interactor.track(
                event: .actionTryTokenize(scheme: .smsSbol, currentAuthType: interactor.analyticsAuthType())
            )
            interactor.tokenizeSberbank(
                phoneNumber: self.phoneNumber,
                savePaymentMethod: self.recurrencySectionSwitchValue ?? false
            )
        }
    }
}

// MARK: - PhoneNumberInputModuleOutput

extension SberbankPresenter: PhoneNumberInputModuleOutput {
    func didChangePhoneNumber(_ phoneNumber: String) {
        self.phoneNumber = phoneNumber
        view?.setSubmitButtonEnabled(!phoneNumber.isEmpty)
    }
}

// MARK: - PaymentRecurrencyAndDataSavingSectionOutput

extension SberbankPresenter: PaymentRecurrencyAndDataSavingSectionOutput {
    func didChangeSwitchValue(newValue: Bool, mode: PaymentRecurrencyAndDataSavingSection.Mode) {
        recurrencySectionSwitchValue = newValue
    }
    func didTapInfoLink(mode: PaymentRecurrencyAndDataSavingSection.Mode) {
        switch mode {
        case .allowRecurring, .requiredRecurring:
            router.presentSafeDealInfo(
                title: CommonLocalized.CardSettingsDetails.autopayInfoTitle,
                body: CommonLocalized.CardSettingsDetails.autopayInfoDetails
            )
        case .savePaymentData, .requiredSaveData:
            router.presentSafeDealInfo(
                title: CommonLocalized.RecurrencyAndSavePaymentData.saveDataInfoTitle,
                body: CommonLocalized.RecurrencyAndSavePaymentData.saveDataInfoMessage
            )
        case .allowRecurringAndSaveData, .requiredRecurringAndSaveData:
            router.presentSafeDealInfo(
                title: CommonLocalized.RecurrencyAndSavePaymentData.saveDataAndAutopaymentsInfoTitle,
                body: CommonLocalized.RecurrencyAndSavePaymentData.saveDataAndAutopaymentsInfoMessage
            )
        default:
        break
        }
    }
}

// MARK: - SberbankModuleInput

extension SberbankPresenter: SberbankModuleInput {}

// MARK: - Private helpers

private extension SberbankPresenter {
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

// MARK: - Localized

private extension SberbankPresenter {
    enum Localized {
        static let phoneInputTitle = NSLocalizedString(
            "Contract.Sberbank.PhoneInput.Title",
            bundle: Bundle.framework,
            value: "Номер в Сбербанк Онлайн",
            comment: "Текст `Номер в Сбербанк Онлайн` https://yadi.sk/i/T-XQGU9NaPMgKA"
        )
        static let phoneInputPlaceholder = NSLocalizedString(
            "Contract.Sberbank.PhoneInput.Placeholder",
            bundle: Bundle.framework,
            value: "+ 7 987 654 32 10",
            comment: "Текст `+ 7 987 654 32 10` https://yadi.sk/i/T-XQGU9NaPMgKA"
        )
        static let phoneInputBottomHint = NSLocalizedString(
            "Contract.Sberbank.PhoneInput.BottomHint",
            bundle: Bundle.framework,
            value: "Для смс от Сбербанка с кодом для оплаты",
            comment: "Текст `Для смс от Сбербанка с кодом для оплаты` https://yadi.sk/i/T-XQGU9NaPMgKA"
        )
    }
}
