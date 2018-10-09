import UIKit
import YandexCheckoutPayments

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)
        let viewController = UINavigationController(rootViewController: RootViewController())
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()

        do {
            try YandexLoginService.activate(withAppId: Constants.YandexLogin.id)
        } catch {
            assertionFailure(error.localizedDescription)
        }

        setupAppearance()

        return true
    }

    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        YandexLoginService.processUserActivity(userActivity)
        return true
    }

    func application(_ application: UIApplication,
                     open url: URL,
                     sourceApplication: String?,
                     annotation: Any) -> Bool {
        return YandexLoginService.handleOpen(url, sourceApplication: sourceApplication)
    }

    @available(iOS 9, *)
    open func application(_ app: UIApplication,
                          open url: URL,
                          options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        return YandexLoginService.handleOpen(url, sourceApplication: options[.sourceApplication] as? String)
    }
}

extension AppDelegate {

    private func setupAppearance() {
        UINavigationBar.appearance().backIndicatorImage = #imageLiteral(resourceName: "Common.Back")
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = #imageLiteral(resourceName: "Common.Back")
    }
}

private extension AppDelegate {
    enum Constants {
        enum YandexLogin {
            static let id = "7767c737cf5747dca8d3bc4689219013"
        }
    }
}
