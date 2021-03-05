import Foundation
import class UIKit.UIImage

final class ImageCacheImpl {

    private let cache = NSCache<AnyObject, AnyObject>()

    init() {
        cache.countLimit = Constants.countLimit
    }
}

// MARK: - ImageCache

extension ImageCacheImpl: ImageCache {

    func getImage(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as AnyObject) as? UIImage
    }

    func setImage(data: Data, forKey key: String) {
        guard let image = UIImage(data: data) else {
            assertionFailure("Can't make image from data")
            return
        }
        cache.setObject(image, forKey: key as AnyObject)
    }

    func removeImage(forKey key: String) {
        cache.removeObject(forKey: key as AnyObject)
    }

    func removeAllImages() {
        cache.removeAllObjects()
    }
}

// MARK: - Constants

private extension ImageCacheImpl {
    enum Constants {
        static let countLimit = 100
    }
}
