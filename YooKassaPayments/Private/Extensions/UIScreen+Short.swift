extension UIScreen {
    var isShort: Bool {
        bounds.height < 600
    }

    var isNarrow: Bool {
        bounds.width < 350
    }
}
