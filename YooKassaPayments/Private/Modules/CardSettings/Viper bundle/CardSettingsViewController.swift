import UIKit

final class CardSettingsViewController: UIViewController, CardSettingsViewInput {
    private let cardDetails = MaskedCardView(frame: .zero)
    private let informer = LargeActionInformer(frame: .zero)
    private let contentContainer = UIStackView(frame: .zero)
    private let actionsContainer = UIStackView(frame: .zero)

    var output: CardSettingsViewOutput!

    private let submitButton: Button = {
        let button = Button(type: .custom)
        button.setTitle(CommonLocalized.Alert.cancel, for: .normal)
        button.style.submit()
        button.addTarget(
            self,
            action: #selector(didPressSubmit),
            for: .touchUpInside
        )
        return button
    }()

    override func loadView() {
        view = UIView(frame: .zero)
        view.setStyles(UIView.Styles.defaultBackground)

        cardDetails.setStyles(
            UIView.Styles.grayBackground,
            UIView.Styles.roundedShadow
        )
        cardDetails.hintCardNumberLabel.setStyles(
            UILabel.DynamicStyle.caption1,
            UILabel.Styles.singleLine,
            UILabel.ColorStyle.primary
        )
        LargeActionInformer.Style.default(informer).alert()
        informer.buttonLabel.text = CommonLocalized.CardSettingsDetails.moreInfo

        contentContainer.axis = .vertical
        contentContainer.spacing = Space.double

        actionsContainer.axis = .vertical
        actionsContainer.spacing = Space.double

        [contentContainer, actionsContainer].forEach { view in
            view.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(view)
        }
        view.layoutMargins = UIEdgeInsets(
            top: Space.double,
            left: Space.double,
            bottom: Space.double,
            right: Space.double
        )

        LargeActionInformer.Style.default(informer).alert()
        informer.actionHandler = { [weak self] in
            self?.output.didPressInformerMoreInfo()
        }

        contentContainer.addArrangedSubview(cardDetails)
        contentContainer.addArrangedSubview(informer)

        actionsContainer.addArrangedSubview(submitButton)
        setupConstraints()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        output.setupView()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            contentContainer.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            contentContainer.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            view.layoutMarginsGuide.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),

            actionsContainer.topAnchor.constraint(equalTo: contentContainer.bottomAnchor, constant: Space.double),
            actionsContainer.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            view.layoutMarginsGuide.trailingAnchor.constraint(equalTo: actionsContainer.trailingAnchor),
            view.layoutMarginsGuide.bottomAnchor.constraint(greaterThanOrEqualTo: actionsContainer.bottomAnchor),
        ])
    }

    @objc
    private func didPressSubmit() {
        output.didPressSubmit()
    }

    // MARK: CardSettingsViewInput

    func set(
        title: String,
        cardMaskHint: String,
        cardLogo: UIImage,
        cardMask: String,
        cardTitle: String,
        informerMessage: String,
        canUnbind: Bool
    ) {
        self.title = title
        cardDetails.hintCardNumber = cardMaskHint
        cardDetails.cardLogo = cardLogo
        cardDetails.cardNumber = cardMask
        informer.messageLabel.styledText = informerMessage

        let title = canUnbind
            ? CommonLocalized.CardSettingsDetails.unbind
            : CommonLocalized.CardSettingsDetails.unwind
        submitButton.setTitle(title, for: .normal)

        if canUnbind {
            submitButton.style.submitAlert(ghostTint: true)
        } else {
            submitButton.style.submit(ghostTint: true)
        }
    }

    func disableSubmit() {
        submitButton.isEnabled = false
    }

    func enableSubmit() {
        submitButton.isEnabled = true
    }

    func hideSubmit(_ hide: Bool) {
        submitButton.isHidden = hide
    }
}

// MARK: - ActivityIndicatorFullViewPresenting

extension CardSettingsViewController: ActivityIndicatorFullViewPresenting {
    func showActivity() {
        showFullViewActivity(style: ActivityIndicatorView.Styles.cloudy)
    }

    func hideActivity() {
        hideFullViewActivity()
    }
}
