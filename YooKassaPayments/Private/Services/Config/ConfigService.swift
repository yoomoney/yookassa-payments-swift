import Foundation
import YooMoneyCoreApi

protocol ConfigService {
    func getConfig(token: String, completion: @escaping (Result<Config, Error>) -> Void)
}
