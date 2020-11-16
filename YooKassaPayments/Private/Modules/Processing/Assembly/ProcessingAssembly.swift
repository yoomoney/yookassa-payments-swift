import UIKit.UIViewController

final class ProcessingAssembly {
    private init?() { return nil }

    static func makeModule() -> UIViewController {
        let viewController = ProcessingViewController()
        return viewController
    }
}
