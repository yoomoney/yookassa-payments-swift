import UIKit

final class NavigationController: UINavigationController {
    weak var moduleOutput: SheetViewModuleOutput?
}

// MARK: - TokenizationModuleInput

extension NavigationController: TokenizationModuleInput {
    func start3dsProcess(requestUrl: String) {
        moduleOutput?.start3dsProcess(requestUrl: requestUrl)
    }
}
