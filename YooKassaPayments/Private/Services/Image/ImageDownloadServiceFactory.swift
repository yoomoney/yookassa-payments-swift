import Foundation

enum ImageDownloadServiceFactory {

    static func makeService(
        session: URLSession = URLSession(configuration: .default),
        cache: ImageCache = ImageCacheImpl()
    ) -> ImageDownloadService {
        return ImageDownloadServiceImpl(session: session, cache: cache)
    }
}
