import class UIKit.UIDevice

enum DeviceInfoServiceAssembly {
    static func makeService() -> DeviceInfoService {
        return DeviceInfoServiceImpl(device: .current)
    }
}
