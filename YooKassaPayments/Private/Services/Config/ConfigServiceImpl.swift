import Foundation
import YooMoneyCoreApi

class ConfigServiceImpl: ConfigService {
    private let session: ApiSession

    let isLoggingEnabled: Bool

    init(session: ApiSession, loginEnabled: Bool) {
        self.session = session
        self.isLoggingEnabled = loginEnabled
    }

    func getConfig(token: String, completion: @escaping (Result<Config, Error>) -> Void) {
        session.perform(apiMethod: ConfigResponse.Method(oauthToken: token)).responseApi { response in
            switch response {
            case .left(let error):
                completion(.failure(error))
            case .right(let response):
                completion(.success(response.config))
            }
        }
    }
}
