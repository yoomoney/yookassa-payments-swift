final class BankCardImageFactoryImpl {
    
    // MARK: - Stored properties
    
    private let bankCardRegex: [BankCardRegex] = [
        BankCardRegex(
            type: .americanExpress,
            regex: "^3[47][0-9]{5,}$"
        ),
        BankCardRegex(
            type: .masterCard,
            regex: "^5[1-5][0-9]{5,}$"
        ),
        BankCardRegex(
            type: .visa,
            regex: "^4[0-9]{6,}$"
        ),
        BankCardRegex(
            type: .mir,
            regex: "^(220[0-4])\\d+$"
        ),
        BankCardRegex(
            type: .maestro,
            regex: "^(5018|5020|5038|5612|5893|6304|6759|6761|6762|6763|0604|6390)\\d+$"
        ),
    ]
}

extension BankCardImageFactoryImpl: BankCardImageFactory {
    
    // MARK: - Make bank card image from card mask
    
    func makeImage(
        _ cardMask: String
    ) -> UIImage? {
        guard let cardType = cardTypeFromCardMask(cardMask) else {
            return nil
        }
        
        let image: UIImage
        switch cardType {
        case .americanExpress:
            image = PaymentMethodResources.Image.americanExpress
        case .masterCard:
            image = PaymentMethodResources.Image.mastercard
        case .visa:
            image = PaymentMethodResources.Image.visa
        case .mir:
            image = PaymentMethodResources.Image.mir
        case .maestro:
            image = PaymentMethodResources.Image.maestro
        }
        return image
    }
    
    private func cardTypeFromCardMask(
        _ cardMask: String
    ) -> BankCardRegexType? {
        for bankCard in bankCardRegex {
            let predicate = NSPredicate(format: "SELF MATCHES %@", bankCard.regex)
            if predicate.evaluate(with: cardMask) {
                return bankCard.type
            }
        }
        return nil
    }
}
