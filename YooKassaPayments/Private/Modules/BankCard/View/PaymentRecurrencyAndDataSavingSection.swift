import UIKit

protocol PaymentRecurrencyAndDataSavingSectionOutput {
    func didChangeSwitchValue(newValue: Bool, mode: PaymentRecurrencyAndDataSavingSection.Mode)
    func didTapInfoLink(mode: PaymentRecurrencyAndDataSavingSection.Mode)
}

class PaymentRecurrencyAndDataSavingSection: UIView, SwitchItemViewOutput, LinkedItemViewOutput {
    enum Mode {
        case empty
        case savePaymentData
        case allowRecurring
        case allowRecurringAndSaveData
        case requiredRecurringAndSaveData
        case requiredRecurring
        case requiredSaveData
    }

    let mode: Mode
    var output: PaymentRecurrencyAndDataSavingSectionOutput?

    private let switchSection = SwitchItemView()
    private let headerSection = SectionHeaderView()
    private let linkSection = LinkedItemView()
    private let innerContainer = UIStackView()

    var switchValue: Bool { switchSection.state }

    private let texts: Config.SavePaymentMethodOptionTexts

    init(mode: Mode, texts: Config.SavePaymentMethodOptionTexts, frame: CGRect = .zero) {
        self.mode = mode
        self.texts = texts
        super.init(frame: frame)

        accessibilityIdentifier = "PaymentRecurrencyAndDataSavingSection"

        innerContainer.axis = .vertical
        innerContainer.translatesAutoresizingMaskIntoConstraints = false

        addSubview(innerContainer)

        NSLayoutConstraint.activate([
            innerContainer.topAnchor.constraint(equalTo: topAnchor),
            innerContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            innerContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            innerContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        switchSection.setStyles(SwitchItemView.Styles.primary)
        switchSection.layoutMargins = .init(
            top: Space.double, left: Space.double, bottom: Space.double, right: Space.double
        )
        headerSection.setStyles(SectionHeaderView.Styles.primary)
        headerSection.layoutMargins = .init(
            top: Space.double, left: Space.double, bottom: 0, right: Space.double
        )
        linkSection.setStyles(LinkedItemView.Styles.linked)
        linkSection.layoutMargins = .init(
            top: Space.single / 4, left: Space.double, bottom: Space.double, right: Space.double
        )

        [switchSection, headerSection, linkSection].forEach { view in
            view.tintColor = CustomizationStorage.shared.mainScheme
            innerContainer.addArrangedSubview(view)
        }

        linkSection.delegate = self
        switchSection.delegate = self

        update()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func switchItemView(_ itemView: SwitchItemViewInput, didChangeState state: Bool) {
        output?.didChangeSwitchValue(newValue: state, mode: mode)
    }

    func didTapOnLinkedView(on itemView: LinkedItemViewInput) {
        output?.didTapInfoLink(mode: mode)
    }

    private func update() {
        typealias HeaderText = CommonLocalized.RecurrencyAndSavePaymentData.Header
        typealias LinkText = CommonLocalized.RecurrencyAndSavePaymentData.Link
        switch mode {
        case .empty:
            innerContainer.arrangedSubviews.forEach { $0.isHidden = true }
        case .savePaymentData:
            headerSection.isHidden = true
            switchSection.title = texts.switchRecurrentOffBindOnTitle
            switchSection.state = true
            linkSection.attributedString = HTMLUtils.highlightHyperlinks(html: texts.switchRecurrentOffBindOnSubtitle)
        case .allowRecurring:
            headerSection.isHidden = true
            switchSection.title = texts.switchRecurrentOnBindOffTitle
            linkSection.attributedString = HTMLUtils.highlightHyperlinks(html: texts.switchRecurrentOnBindOffSubtitle)
        case .allowRecurringAndSaveData:
            headerSection.isHidden = true
            switchSection.title = texts.switchRecurrentOnBindOnTitle
            linkSection.attributedString = HTMLUtils.highlightHyperlinks(html: texts.switchRecurrentOnBindOnSubtitle)
        case .requiredRecurringAndSaveData:
            switchSection.isHidden = true
            headerSection.title = texts.messageRecurrentOnBindOnTitle
            linkSection.attributedString = HTMLUtils.highlightHyperlinks(html: texts.messageRecurrentOnBindOnSubtitle)
        case .requiredRecurring:
            switchSection.isHidden = true
            headerSection.title = texts.messageRecurrentOnBindOffTitle
            linkSection.attributedString = HTMLUtils.highlightHyperlinks(html: texts.messageRecurrentOnBindOffSubtitle)
        case .requiredSaveData:
            switchSection.isHidden = true
            headerSection.title = texts.messageRecurrentOffBindOnTitle
            linkSection.attributedString = HTMLUtils.highlightHyperlinks(html: texts.messageRecurrentOffBindOnSubtitle)
        }
    }
}
