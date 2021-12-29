import Foundation

import Foundation

/// Possible log level enumeration
enum LogLevel {
    /// Lowest level. Most fine-grain info. One can expect the trace level to be very verbose. You can use it
    /// for example to annotate each step in the algorithm or each individual query with parameters in your code.
    case trace

    /// Less granular compared to the TRACE level, but it is more than you will need in everyday use.
    /// The DEBUG log level should be used for information that may be needed for diagnosing issues and
    /// troubleshooting or when running application in the test environment for the purpose of
    /// making sure everything is running correctly
    case debug

    /// The standard log level indicating that something happened, the application entered a certain state, etc.
    /// For example, a controller of your authorization API may include an INFO log level with information on which
    /// user requested authorization if the authorization was successful or not. The information logged using the
    /// `info` log level should be purely informative and not looking into them on a regular basis shouldn’t
    /// result in missing any important information.
    case info

    /// The log level that indicates that something unexpected happened in the application, a problem, or a situation
    /// that might disturb one of the processes. But that doesn’t mean that the application failed. The `warn` level
    /// should be used in situations that are unexpected, but the code can continue the work.
    /// For example, a parsing error occurred that resulted in a certain document not being processed.
    case warn

    /// The log level that should be used when the application hits an issue preventing one or more functionalities
    /// from properly functioning. The `error` log level can be used when one of the payment systems is not available,
    /// but there is still the option to check out the basket in the e-commerce application or when your social media
    /// logging option is not working for some reason.
    case error

    /// The log level that tells that the application encountered an event or entered a state in which one of the
    /// crucial business functionality is no longer working. A FATAL log level may be used when the application is
    /// not able to connect to a crucial data store like a database or all the payment systems are not available
    /// and users can’t checkout their baskets in your e-commerce.
    case fatal
}

extension LogLevel {
    /// Default tag
    var tag: String {
        switch self {
        case .trace: return "🕵🏻‍♂️"
        case .debug: return "🇩🇪🐛"
        case .info: return "💬"
        case .warn: return "⚠️"
        case .error: return "⛑"
        case .fatal: return "🔥☠️🔥☠️🔥"
        }
    }
}

extension LogLevel: CustomStringConvertible {
    public var description: String {
        switch self {
        case .trace: return "TRACE"
        case .debug: return "DEBUG"
        case .info: return "INFO"
        case .warn: return "WARN"
        case .error: return "ERROR"
        case .fatal: return "FATAL"
        }
    }
}

extension LogLevel: Comparable {}

/// Logger interface
protocol Logger {
    /// Log message with level. Also add optional tag and/or additional info.
    static func log(_ message: String, level: LogLevel, tag: String?, info: [String: String]?)
}

extension Logger {
    /// if `DEBUG` logs message and info, if any, to console with `.trace` log level using that level tag
    static func trace(_ message: String, info: [String: String]? = nil) {
        #if DEBUG
        let level = LogLevel.trace
        log(message, level: level, tag: level.tag, info: info)
        #endif
    }

    /// if `DEBUG` logs message and info, if any, to console with `.debug` log level using that level tag
    static func debug(_ message: String, info: [String: String]? = nil) {
        #if DEBUG
        let level = LogLevel.debug
        log(message, level: level, tag: level.tag, info: info)
        #endif
    }

    /// Log message and info, if any, to console with `.info` log level using that level tag
    static func info(_ message: String, info: [String: String]? = nil) {
        let level = LogLevel.info
        log(message, level: level, tag: level.tag, info: info)
    }

    /// Log message and info, if any, to console with `.warn` log level using that level tag
    static func warn(_ message: String, info: [String: String]? = nil) {
        let level = LogLevel.warn
        log(message, level: level, tag: level.tag, info: info)
    }

    /// Log message and info, if any, to console with `.warn` log level using that level tag
    static func debugWarn(_ message: String, info: [String: String]? = nil) {
        #if DEBUG
        let level = LogLevel.warn
        log(message, level: level, tag: level.tag, info: info)
        #endif
    }

    /// Log message and info, if any, to console with `.error` log level using that level tag
    static func error(_ message: String, info: [String: String]? = nil) {
        let level = LogLevel.error
        log(message, level: level, tag: level.tag, info: info)
    }

    /// Log message and info, if any, to console with `.fatal` log level using that level tag
    static func fatal(_ message: String, info: [String: String]? = nil) {
        let level = LogLevel.fatal
        log(message, level: level, tag: level.tag, info: info)
    }
}

/// Log using `print()`
struct PrintLogger: Logger {
    private static let title = "PrintLogger"

    /// Logging messages >= than `level`. Global filter
    static var level: LogLevel = .info
    static var forceSilence = false

    private enum PrintLoggerError: Error {
        case prettyFailed
    }

    private static func pretty(_ some: Any) throws -> String {
        let data = try JSONSerialization.data(withJSONObject: some, options: .prettyPrinted)
        guard let string = String(data: data, encoding: .utf8) else {
            throw PrintLoggerError.prettyFailed
        }
        return string
    }

    static func log(_ message: String, level: LogLevel, tag: String?, info: [String: String]?) {
        guard level >= PrintLogger.level, !PrintLogger.forceSilence else { return }
        let tagText = tag ?? ""
        print(tagText + "=====" + " \(title)" + "=====")

        var log: [Any] = [
            "LOG LEVEL: \(level)",
            "MESSAGE: \(message)",
        ]
        info
            .map { unwrapped -> String in
                if let pretty = try? pretty(unwrapped) {
                    return pretty
                }
                return unwrapped.description
            }
            .map { log.append("INFO: \($0)") }

        log.forEach { print($0) }
        print(tagText + "=====")
    }
}
