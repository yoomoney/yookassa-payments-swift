/// Setting for saving payment method. If payment method is saved, shop can make recurring payments with a token.
///
/// There are three options for this setting:
///
/// `on` - always save payment method. User can select only from payment methods, that allow saving.
/// On the contract screen user will see a message about saving his payment method.
///
/// `off` - don't save payment method. User can select from all of the available payment methods.
///
/// `userSelects` - user chooses to save payment method (user will have a switch to change
/// selection, if payment method can be saved).
public enum SavePaymentMethod {
    /// Always save payment method. User can select only from payment methods, that allow saving.
    /// On the contract screen user will see a message about saving his payment method.
    case on
    /// Don't save payment method. User can select from all of the available payment methods.
    case off
    /// User chooses to save payment method (user will have a switch to change selection,
    /// if payment method can be saved).
    case userSelects
}
