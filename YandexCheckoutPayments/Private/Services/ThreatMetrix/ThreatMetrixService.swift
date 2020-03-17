/* The MIT License
 *
 * Copyright (c) 2018 NBCO Yandex.Money LLC
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

import FunctionalSwift
import TMXProfiling
import When

/// Profiling error or session id
typealias ThreatMetrixProfilingCompletionHandler = (FunctionalSwift.Result<String>) -> Void

/// Service to manage threat metrix.
/// ThreatMetrix should be configured on app start up.
/// ThreatMetrix uses location service.
class ThreatMetrixService {
    static var isConfigured = false

    fileprivate static var currentProfilingCallback: ThreatMetrixProfilingCompletionHandler?
    fileprivate static let threatMetrixQueue = DispatchQueue(label: "ru.yandex.mobile.money.queue.threatMetrix",
                                                             qos: .userInteractive)
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
                TMXFingerprintServer: "s4.money.yandex.net",
            ])
            isConfigured = true
        }
    }

    /// Perform a profiling request by threatmetrix. Can do profiling with single callback.
    /// If called while already profiling, previous callback will be called with interrupted state.
    ///
    /// - Parameter completion: callback contains error or session id on success
    static func profileApp() -> Promise<String> {

        let promise: Promise<String> = Promise()

        threatMetrixQueue.async {

            guard isConfigured else {
                assertionFailure("ThreatMetrix must be configured before profiling")
                promise.reject(ProfileError.invalidConfiguration)
                return
            }

            ThreatMetrixService.currentProfilingCallback?(.left(ProfileError.interrupted))
            ThreatMetrixService.currentProfilingCallback = {
                $0.bimap(promise.reject, promise.resolve)
            }

            ThreatMetrixService.profileHandler =
                TMXProfiling.sharedInstance()?.profileDevice { profilingResult in
                    ThreatMetrixService.profileHandler = nil
                    handleProfilingResult(profilingResult)
                }
        }

        return promise
    }

    private static func handleProfilingResult(_ result: [AnyHashable: Any]?) {
        var sessionId: String?
        var error: ProfileError?

        defer {
            if let sessionId = sessionId {
                ThreatMetrixService.currentProfilingCallback?(.right(sessionId))
            } else {
                ThreatMetrixService.currentProfilingCallback?(.left(error ?? ProfileError.internalError))
            }
            ThreatMetrixService.currentProfilingCallback = nil
        }

        guard let parameters = result,
              let statusRawValue = parameters[TMXProfileStatus] as? NSNumber,
              let status = TMXStatusCode(rawValue: statusRawValue.intValue) else {
            error = .internalError
            return
        }

        switch status {
        case .ok:
            sessionId = parameters[TMXSessionID] as? String

        case .internalError:
            error = .internalError

        case .connectionError,
             .hostNotFoundError,
             .networkTimeoutError,
             .partialProfile,
             .profilingTimeoutError: //partialProfile called when not all api requests were made, because of bad connection
            error = .connectionFail

        case .interruptedError:
            error = .interrupted

        case .hostVerificationError,
             .invalidOrgID,
             .notConfigured,
             .invalidParameter,
             .certificateMismatch,
             .notYet:
            error = .invalidConfiguration
        }
    }

    /// Cancel current profiling
    static func cancelProfiling() {
        threatMetrixQueue.async {
            ThreatMetrixService.currentProfilingCallback?(.left(ProfileError.interrupted))
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
