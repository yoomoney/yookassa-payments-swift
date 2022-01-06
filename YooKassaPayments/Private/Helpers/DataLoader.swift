import Foundation

class DataLoader {
    let urls: [URL]
    private let loadingGroup = DispatchGroup()
    private let session = URLSession.shared
    private var loadingResult: [URL: Result<Data, Error>] = [:]
    private(set) var isLoading = false

    enum LoadingError: Error {
        case unknown
    }

    init(urls: [URL]) {
        self.urls = urls
    }

    private var tasks: [URLSessionDataTask] = []

    func load(completion: @escaping ([URL: Result<Data, Error>]) -> Void) {
        guard !isLoading else {
            PrintLogger.debugWarn("Multiple load calls", info: ["object": String(describing: self)] )
            return
        }

        isLoading = true
        urls.forEach { targetUrl in
            loadingGroup.enter()
            let task = session.dataTask(with: targetUrl) { [weak self] data, _, error in
                guard let self = self else { return }
                self.loadingGroup.leave()
                let result: Result<Data, Error> = data.map { .success($0) }
                    ?? error.map { .failure($0) }
                    ?? .failure(LoadingError.unknown)
                self.loadingResult[targetUrl] = result
            }
            tasks.append(task)
            task.resume()
        }

        loadingGroup.notify(queue: .global()) { [weak self] in
            guard let self = self else { return }
            self.tasks = []
            completion(self.loadingResult)
        }
    }
}
