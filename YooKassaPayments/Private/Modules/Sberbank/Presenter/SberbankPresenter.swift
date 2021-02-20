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
    private let termsOfService: TermsOfService
    private let userPhoneNumber: String?
    private let isBackBarButtonHidden: Bool

    init(
        shopName: String,
        purchaseDescription: String,
        priceViewModel: PriceViewModel,
        feeViewModel: PriceViewModel?,
        termsOfService: TermsOfService,
        userPhoneNumber: String?,
        isBackBarButtonHidden: Bool
    ) {
        self.shopName = shopName
        self.purchaseDescription = purchaseDescription
        self.priceViewModel = priceViewModel
        self.feeViewModel = feeViewModel
        self.termsOfService = termsOfService
        self.userPhoneNumber = userPhoneNumber
        self.isBackBarButtonHidden = isBackBarButtonHidden
    }

    // MARK: - Stored properties

    private var phoneNumber: String = ""
}

// MARK: - SberbankViewOutput

extension SberbankPresenter: SberbankViewOutput {
    func setupView() {
        guard let view = view else { return }
        let priceValue = makePrice(priceViewModel)

        var feeValue: String? = nil
        if let feeViewModel = feeViewModel {
            feeValue = "\(§Localized.fee) " + makePrice(feeViewModel)
        }

        let termsOfServiceValue = makeTermsOfService(
            termsOfService,
            font: UIFont.dynamicCaption2,
            foregroundColor: UIColor.AdaptiveColors.secondary
        )
        let viewModel = SberbankViewModel(
            shopName: shopName,
            description: purchaseDescription,
            priceValue: priceValue,
            feeValue: feeValue,
            termsOfService: termsOfServiceValue
        )
        view.setViewModel(viewModel)

        let title = §Localized.phoneInputTitle
        phoneNumberModuleInput?.setTitle(title.uppercased())
        phoneNumberModuleInput?.setPlaceholder(§Localized.phoneInputPlaceholder)
        phoneNumberModuleInput?.setSubtitle(§Localized.phoneInputBottomHint)

        if let userPhoneNumber = userPhoneNumber {
            phoneNumberModuleInput?.setValue(userPhoneNumber)
        }

        view.setBackBarButtonHidden(isBackBarButtonHidden)

        DispatchQueue.global().async { [weak self] in
            guard let self = self,
                  let interactor = self.interactor else { return }
            let (authType, _) = interactor.makeTypeAnalyticsParameters()
            let event: AnalyticsEvent = .screenPaymentContract(
                authType: authType,
                scheme: .smsSbol
            )
            interactor.trackEvent(event)
        }
    }

    func didPressSubmitButton() {
        guard let view = view else { return }
        view.endEditing(true)
        view.showActivity()
        DispatchQueue.global().async { [weak self] in
            guard let self = self,
                  let interactor = self.interactor else { return }
            interactor.tokenizeSberbank(phoneNumber: self.phoneNumber)
        }
    }

    func didPressTermsOfService(
        _ url: URL
    ) {
        router.presentTermsOfServiceModule(url)
    }
}

// MARK: - SberbankInteractorOutput

extension SberbankPresenter: SberbankInteractorOutput {
    func didTokenize(
        _ data: Tokens
    ) {
        let analyticsParameters = interactor.makeTypeAnalyticsParameters()
        let event: AnalyticsEvent = .actionTokenize(
            scheme: .smsSbol,
            authType: analyticsParameters.authType,
            tokenType: analyticsParameters.tokenType
        )
        interactor.trackEvent(event)
        moduleOutput?.sberbankModule(
            self, didTokenize: data,
            paymentMethodType: .sberbank
        )
    }

    func didFailTokenize(
        _ error: Error
    ) {
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
            guard let self = self,
                  let interactor = self.interactor else { return }
            interactor.tokenizeSberbank(phoneNumber: self.phoneNumber)
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
            message = §CommonLocalized.Error.unknown
        }

        return message
    }
}

// MARK: - Localized

private extension SberbankPresenter {
    enum Localized: String {
        case phoneInputTitle = "Contract.Sberbank.PhoneInput.Title"
        case phoneInputPlaceholder = "Contract.Sberbank.PhoneInput.Placeholder"
        case phoneInputBottomHint = "Contract.Sberbank.PhoneInput.BottomHint"
        case fee = "Contract.fee"
    }
}
