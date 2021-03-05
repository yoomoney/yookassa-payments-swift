import Foundation
import class UIKit.UIImage

enum ImageDownloadServiceError: Error {
    case incorrectData
}

protocol ImageDownloadService {
    func fetchImage(
        url: URL,
        completion: @escaping (Result<UIImage, Error>) -> Void
    )
}
