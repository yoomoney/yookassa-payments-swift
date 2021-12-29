import UIKit

final class CardSettingsPresenter: CardSettingsViewOutput, CardSettingsInteractorOutput {
    weak var view: CardSettingsViewInput!
    weak var output: CardSettingsModuleOutput!

    var interactor: CardSettingsInteractorInput!
    var router: CardSettingsRouterInput!
    let paymentMethodViewModelFactory: PaymentMethodViewModelFactory

    private let data: CardSettingsModuleInputData
    init(data: CardSettingsModuleInputData, paymentMethodViewModelFactory: PaymentMethodViewModelFactory) {
        self.data = data
        self.paymentMethodViewModelFactory = paymentMethodViewModelFactory
    }

    func setupView() {
        typealias Text = CommonLocalized.CardSettingsDetails
        let canUnbind: Bool
        let displayName: String
        let cardTitle: String
        let cardMaskHint: String
        switch data.card {
        case .yoomoney(let name):
            displayName = name ?? data.cardMask
            cardTitle = name ?? PaymentMethodResources.Localized.yooMoneyCard
            canUnbind = false
            cardMaskHint = PaymentMethodResources.Localized.yooMoneyCard
            view.hideSubmit(true)
            interactor.track(event: .screenUnbindCard(cardType: .wallet))
        case .card(let name, _):
            displayName = name
            cardTitle = PaymentMethodResources.Localized.linkedCard
            canUnbind = true
            cardMaskHint = PaymentMethodResources.Localized.bankCard
            view.hideSubmit(false)
            interactor.track(event: .screenUnbindCard(cardType: .bankCard))
        }

        view.set(
            title: displayName,
            cardMaskHint: cardMaskHint,
            cardLogo: data.cardLogo,
            cardMask: paymentMethodViewModelFactory.replaceBullets(data.cardMask.splitEvery(4, separator: " ")),
            cardTitle: cardTitle,
            informerMessage: data.infoText,
            canUnbind: canUnbind
        )
    }

    func didPressSubmit() {
        view.disableSubmit()
        switch data.card {
        case .yoomoney:
            output.cardSettingsModuleDidCancel()
        case .card(_, let id):
            view.showActivity()

            DispatchQueue.global().async { [weak self] in
                guard let self = self else { return }
                self.interactor.unbind(id: id)
            }

        }
    }
    func didPressCancel() {
        output.cardSettingsModuleDidCancel()
    }
    func didPressInformerMoreInfo() {
        switch data.card {
        case .yoomoney:
            router.openInfo(
                title: CommonLocalized.CardSettingsDetails.unbindInfoTitle,
                details: CommonLocalized.CardSettingsDetails.unbindInfoDetails
            )
            interactor.track(event: .screenDetailsUnbindWalletCard)
        case .card:
            router.openInfo(
                title: CommonLocalized.CardSettingsDetails.autopayInfoTitle,
                details: CommonLocalized.CardSettingsDetails.autopayInfoDetails
            )
        }
    }

    // MARK: - CardSettingsInteractorOutput

    func didFailUnbind(error: Error, id: String) {
        interactor.track(event: .actionUnbindBankCard(success: false))
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.view.hideActivity()
            self.view.enableSubmit()
            self.view.presentError(
                with: String(format: CommonLocalized.CardSettingsDetails.unbindFail, self.data.cardMask)
            )
        }
    }

    func didUnbind(id: String) {
        interactor.track(event: .actionUnbindBankCard(success: true))
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.view.enableSubmit()
            self.view.hideActivity()
            self.output.cardSettingsModuleDidUnbindCard(mask: self.data.cardMask)
        }
    }
}
