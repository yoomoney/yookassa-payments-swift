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

        setupAppearance()
        registerSettingsBundle()

        return true
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
