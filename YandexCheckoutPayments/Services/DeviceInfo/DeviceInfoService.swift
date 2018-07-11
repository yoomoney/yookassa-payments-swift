import class UIKit.UIDevice

class DeviceInfoService: DeviceInfoProvider {

    let device: UIDevice

    init(device: UIDevice) {
        self.device = device
    }

    func getDeviceName() -> String {
        return device.name
    }
}
