import Foundation
import class UIKit.UIImage

final class ImageDownloadServiceImpl {

    // MARK: - Init data
    
    private let session: URLSession
    private let cache: ImageCache

    // MARK: - Init
    
    init(
        session: URLSession,
        cache: ImageCache
    ) {
        self.session = session
        self.cache = cache
    }
}

// MARK: - ImageDownloadService

extension ImageDownloadServiceImpl: ImageDownloadService {
    func fetchImage(
        url: URL,
        completion: @escaping (Result<UIImage, Error>) -> Void
    ) {
        if let image = cache.getImage(forUrl: url) {
            return completion(.success(image))
        }
        session.dataTask(with: url) { [weak self] (data, _, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let imageData = data,
                  let image = UIImage(data: imageData) else {
                completion(.failure(ImageDownloadServiceError.incorrectData))
                return
            }
            self?.cache.setImage(data: imageData, forUrl: url)
            completion(.success(image))
        }.resume()
    }
}
