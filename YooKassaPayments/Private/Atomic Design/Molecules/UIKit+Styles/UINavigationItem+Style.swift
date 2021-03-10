// MARK: - Styles

extension UINavigationItem {

    enum Styles {
        static let onlySmallTitle = InternalStyle(name: "onlySmallTitle") { (navigationItem: UINavigationItem) in
            if #available(iOS 11.0, *) {
                navigationItem.largeTitleDisplayMode = .never
            }
        }
    }
}
