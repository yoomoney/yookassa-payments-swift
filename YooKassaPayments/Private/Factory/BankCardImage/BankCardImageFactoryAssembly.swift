enum BankCardImageFactoryAssembly {
    static func makeFactory() -> BankCardImageFactory {
        return BankCardImageFactoryImpl()
    }
}
