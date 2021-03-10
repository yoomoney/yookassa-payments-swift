import Foundation
import class UIKit.UIImage

protocol ImageProvider {
    func getImage(forKey key: String) -> UIImage?
}
