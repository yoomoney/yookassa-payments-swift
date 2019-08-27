import UIKit

enum SelectOptionModuleAssembly {

    static func makeModule(item: SelectDisplayItem,
                           selectOption: SelectOptionDisplayItem?,
                           moduleOutput: SelectOptionModuleOutput?) -> UINavigationController {

        let view = SelectOptionViewController()
        view.output = moduleOutput
        view.displayItems = item.options
        view.selectOption = selectOption
        view.navigationItem.title = item.title

        let navigation = UINavigationController(rootViewController: view)

        if #available(iOS 11.0, *) {
            navigation.navigationBar.prefersLargeTitles = true
        }

        return navigation
    }
}
