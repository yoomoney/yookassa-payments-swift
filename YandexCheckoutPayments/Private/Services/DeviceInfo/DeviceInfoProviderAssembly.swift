import class UIKit.UIDevice

enum DeviceInfoProviderAssembly {
    static func makeDeviceInfoProvider() -> DeviceInfoProvider {
        return DeviceInfoService(device: .current)
    }
}
