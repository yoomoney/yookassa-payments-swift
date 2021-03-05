import Foundation
import class UIKit.UIImage

protocol ImageCache: ImageProvider {
    func setImage(data: Data, forKey key: String)
    func removeImage(forKey key: String)
    func removeAllImages()
}

extension ImageCache {

    func getImage(forUrl url: URL) -> UIImage? {
        return getImage(forKey: url.absoluteString)
    }

    func setImage(data: Data, forUrl url: URL) {
        setImage(data: data, forKey: url.absoluteString)
    }

    func removeImage(forUrl url: URL) {
        removeImage(forKey: url.absoluteString)
    }
}
