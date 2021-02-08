protocol TokenizationViewOutput: class {
    func setupView()
    func closeDidPress()
}

protocol TokenizationViewInput: class {
    func setCustomizationSettings()
}
