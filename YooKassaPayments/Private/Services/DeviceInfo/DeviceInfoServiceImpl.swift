import class UIKit.UIDevice

class DeviceInfoServiceImpl {

    // MARK: - Init data

    let device: UIDevice

    // MARK: - Init

    init(device: UIDevice) {
        self.device = device
    }
}

// MARK: - DeviceInfoService

extension DeviceInfoServiceImpl: DeviceInfoService {
    func getDeviceName() -> String {
        return device.name
    }
}
