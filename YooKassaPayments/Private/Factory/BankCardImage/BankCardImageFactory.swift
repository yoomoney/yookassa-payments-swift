protocol BankCardImageFactory {
    
    // MARK: - Make bank card image from card mask
    
    func makeImage(
        _ cardMask: String
    ) -> UIImage?
}
