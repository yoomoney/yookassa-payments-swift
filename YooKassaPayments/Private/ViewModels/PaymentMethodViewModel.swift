import UIKit.UIImage

struct PaymentMethodViewModel {
    let id: String?
    let isShopLinkedCard: Bool
    let image: UIImage
    let title: String
    let subtitle: String?
    let hasActions: Bool

    init(
        id: String?,
        isShopLinkedCard: Bool,
        image: UIImage,
        title: String,
        subtitle: String?,
        hasActions: Bool = false
    ) {
        self.id = id
        self.isShopLinkedCard = isShopLinkedCard
        self.image = image
        self.title = title
        self.subtitle = subtitle
        self.hasActions = hasActions
    }
}
