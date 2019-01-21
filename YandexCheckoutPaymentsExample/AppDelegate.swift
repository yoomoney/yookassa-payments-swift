import UIKit
import YandexCheckoutPayments

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

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
        registerSettingsBundle()

        return true
    }

    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
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
                          options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return YandexLoginService.handleOpen(url, sourceApplication: options[.sourceApplication] as? String)
    }

    private func registerSettingsBundle() {
        let userDefaults = UserDefaults.standard
        userDefaults.synchronize()

        guard let settingsBundlePath = Bundle.main.path(forResource: "Settings", ofType: "bundle"),
              let settingsBundle = Bundle(path: settingsBundlePath),
              let rootPath = settingsBundle.path(forResource: "Root", ofType: "plist"),
              let settings = NSDictionary(contentsOfFile: rootPath),
              let preferences = settings["PreferenceSpecifiers"] as? [[String: Any]] else {
            return
        }

        let defaultPairs = preferences.compactMap { (data) -> (String, Any)? in
            guard let key = data["Key"] as? String,
                  let value = data["DefaultValue"] else {
                return nil
            }

            return (key, value)
        }

        let defaultsToRegister = defaultPairs.reduce(into: [:]) { $0[$1.0] = $1.1 }

        userDefaults.register(defaults: defaultsToRegister)
        userDefaults.synchronize()
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
