import Dispatch
import FunctionalSwift
import When
import YooMoneyCoreApi

extension Task {
    func responseApi() -> Promise<R> {
        let queue = DispatchQueue.global()

        let promise = Promise<R>(queue: queue)

        responseApi(queue: queue) {
            $0.bimap(promise.reject, promise.resolve)
        }

        return promise
    }
}
