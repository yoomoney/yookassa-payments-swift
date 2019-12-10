import class UIKit.UIView
import struct UIKit.UIEdgeInsets

enum ContractViewFactory {
    static func makePaymentMethodView(paymentMethod: PaymentMethodViewModel,
                                      viewOutput: ContractViewOutput,
                                      shouldChangePaymentMethod: Bool) -> UIView & PaymentMethodViewInput {
        let itemView: UIView & PaymentMethodViewInput
        switch (paymentMethod.balance, shouldChangePaymentMethod) {
        case (.none, false):
            itemView = makeItemView()
        case (.some, false):
            itemView = makeLargeItemView(viewOutput: viewOutput)
        case (.none, true):
            itemView = makeIconButtonItemView(viewOutput: viewOutput)
        case (.some, true):
            itemView = makeLargeIconButtonItemView(viewOutput: viewOutput)
        }
        return itemView
    }

    static func makeSwitchItemView(_ customizationSettings: CustomizationSettings) -> SwitchItemView {
        let switchItemView = SwitchItemView()
        switchItemView.setStyles(SwitchItemView.Styles.secondary)
        switchItemView.tintColor = customizationSettings.mainScheme
        switchItemView.layoutMargins = UIEdgeInsets(top: Space.double, left: 0, bottom: Space.double, right: 0)
        return switchItemView
    }

    private static func makeItemView() -> IconItemView {
        let itemView = IconItemView()
        itemView.layoutMargins = UIEdgeInsets(top: Space.double, left: 0, bottom: Space.double, right: 0)
        return itemView
    }

    private static func makeLargeItemView(viewOutput: ContractViewOutput) -> LargeIconItemView {
        let itemView = LargeIconItemView()
        itemView.layoutMargins = UIEdgeInsets(top: Space.double, left: 0, bottom: Space.double, right: 0)
        itemView.output = viewOutput
        return itemView
    }

    private static func makeIconButtonItemView(viewOutput: ContractViewOutput) -> IconButtonItemView {
        let itemView = IconButtonItemView()
        itemView.layoutMargins = UIEdgeInsets(top: Space.double, left: 0, bottom: Space.double, right: 0)
        itemView.output = viewOutput
        return itemView
    }

    private static func makeLargeIconButtonItemView(viewOutput: ContractViewOutput) -> LargeIconButtonItemView {
        let itemView = LargeIconButtonItemView()
        itemView.layoutMargins = UIEdgeInsets(top: Space.double, left: 0, bottom: Space.double, right: 0)
        itemView.output = viewOutput
        return itemView
    }
}
