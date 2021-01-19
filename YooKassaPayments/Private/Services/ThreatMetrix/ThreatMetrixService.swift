/* The MIT License
 *
 * Copyright © 2020 NBCO YooMoney LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import TMXProfiling

/// Profiling error or session id
typealias ThreatMetrixProfilingCompletionHandler = (Result<String, Error>) -> Void

/// Service to manage threat metrix.
/// ThreatMetrix should be configured on app start up.
/// ThreatMetrix uses location service.
class ThreatMetrixService {
    static var isConfigured = false

    fileprivate static var currentProfilingCallback: ThreatMetrixProfilingCompletionHandler?
    fileprivate static let threatMetrixQueue = DispatchQueue(
        label: "ru.yookassa.payments.queue.threatMetrix",
        qos: .userInteractive
    )
    fileprivate static var profileHandler: TMXProfileHandle?

    /// Initialize ThreatMetrix SDK
    static func configure() {
        threatMetrixQueue.async {
            guard isConfigured == false else { return }

            TMXProfiling.sharedInstance()?.configure(configData: [
                // (Mandatory) Specifies the Org ID. NSString
                TMXOrgID: "fsymclue",

                // (OPTIONAL) Set the connection timeout, in seconds
                TMXProfileTimeout: 10,

                // (OPTIONAL) Register for location service updates
                TMXLocationServices: false,

                // (OPTIONAL) This is the  fully qualified domain name (FQDN) of the server that ThreatMetrix SDK
                // will communicate with to transmit the collected device attributes.
                // This will only need to be explicitly specified if you have Enhanced Profiling configured.
                // This parameter must be specified in a FQDN format, eg: host.domain.com
                TMXFingerprintServer: "s4.partner.yoomoney.ru",
            ])
            isConfigured = true
        }
    }

    /// Perform a profiling request by threatmetrix. Can do profiling with single callback.
    /// If called while already profiling, previous callback will be called with interrupted state.
    ///
    /// - Parameter completion: callback contains error or session id on success
    static func profileApp(
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        threatMetrixQueue.async {

            guard isConfigured else {
                assertionFailure("ThreatMetrix must be configured before profiling")
                completion(.failure(ProfileError.invalidConfiguration))
                return
            }

            ThreatMetrixService.currentProfilingCallback?(.failure(ProfileError.interrupted))
            ThreatMetrixService.currentProfilingCallback = {
                completion($0)
            }

            ThreatMetrixService.profileHandler =
                TMXProfiling.sharedInstance()?.profileDevice { profilingResult in
                    ThreatMetrixService.profileHandler = nil
                    handleProfilingResult(profilingResult)
                }
        }
    }

    private static func handleProfilingResult(_ result: [AnyHashable: Any]?) {
        let profilingResult: String

        let status = (result?[TMXProfileStatus] as? Int).flatMap(TMXStatusCode.init)
        if status == .notYet, currentProfilingCallback != nil {
            TMXProfiling.sharedInstance()?.profileDevice { result in
                ThreatMetrixService.profileHandler = nil
                handleProfilingResult(result)
            }
            return
        }

        if let sessionId = result?[TMXSessionID] as? String, status == .ok {
            profilingResult = sessionId
        } else {
            profilingResult = (status ?? .internalError).thmErrorCode
        }
        currentProfilingCallback?(.success(profilingResult))
        currentProfilingCallback = nil
    }

    /// Cancel current profiling
    static func cancelProfiling() {
        threatMetrixQueue.async {
            ThreatMetrixService.currentProfilingCallback?(.failure(ProfileError.interrupted))
            ThreatMetrixService.currentProfilingCallback = nil
            ThreatMetrixService.profileHandler?.cancel()
        }
    }
}

extension ThreatMetrixService {
    enum ProfileError: Error {
        case connectionFail
        case invalidConfiguration
        case internalError
        case interrupted
    }
}

extension TMXStatusCode {
    var thmErrorCode: String {
        switch self {
        case .notYet:
            return "TMX_NOT_YET"
        case .ok:
            return "TMX_OK"
        case .connectionError:
            return "TMX_CONNECTION_ERROR"
        case .hostNotFoundError:
            return "TMX_HOST_NOT_FOUND_ERROR"
        case .networkTimeoutError:
            return "TMX_NETWORK_TIMEOUT_ERROR"
        case .hostVerificationError:
            return "TMX_HOST_VERIFICATION_ERROR"
        case .internalError:
            return "TMX_INTERNAL_ERROR"
        case .interruptedError:
            return "TMX_INTERRUPTED_ERROR"
        case .partialProfile:
            return "TMX_PARTIAL_PROFILE"
        case .invalidOrgID:
            return "TMX_INVALID_ORG_ID"
        case .notConfigured:
            return "TMX_NOT_CONFIGURED"
        case .certificateMismatch:
            return "TMX_CERTIFICATE_MISMATCH"
        case .invalidParameter:
            return "TMX_INVALID_PARAMETER"
        case .profilingTimeoutError:
            return "TMX_PROFILING_TIMEOUT_ERROR"
        default:
            return "UNKNOWN_ERROR_CODE_\(self.rawValue)"
        }
    }
}
