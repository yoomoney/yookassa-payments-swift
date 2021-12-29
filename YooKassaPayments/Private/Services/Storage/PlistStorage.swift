import Foundation

/// A simple storage not ment for storing large amounts of data
/// If you need to store significant amount (>10MB) use sqlite or other
class PlistStorage: KeyValueStoring {
    private let decoder = PropertyListDecoder()
    private let encoder = PropertyListEncoder()
    private let storageUrl: URL
    init(storageUrl: URL) {
        writeQueue = DispatchQueue(label: "com.writeQueue.PlistStorage", attributes: .concurrent)
        self.storageUrl = storageUrl
        setup()
    }

    private func setup() {
        do {
            _ = try Data(contentsOf: storageUrl)
        } catch {
            PrintLogger.trace("Read storage failed", info: ["error": error.localizedDescription])
            setupEmpty()
        }
    }

    private func setupEmpty() {
        do {
            PrintLogger.trace("Attempting to setup empty storage")
            let empty = try PropertyListEncoder().encode([String: String]())
            try empty.write(to: storageUrl, options: .atomic)
        } catch {
            PrintLogger.error(
                "Setup empty storage failed",
                info: [
                    "error": error.localizedDescription,
                    "storageUrl": storageUrl.debugDescription,
                ]
            )
        }
    }

    // MARK: - KeyValueStoring implementation
    let writeQueue: DispatchQueue
    func write<T>(value: T?, for key: String) throws where T: Encodable {
        try writeQueue.sync(flags: .barrier) {
            do {
                PrintLogger.trace(
                    "Plist storage writing",
                    info: ["key": key]
                )
                let storage = try Data(contentsOf: storageUrl)
                var target = try decoder.decode(Dictionary<String, Data>.self, from: storage)
                target[key] = try encoder.encode(value)
                let update = try encoder.encode(target)
                try update.write(to: storageUrl, options: .atomicWrite)
            } catch {
                PrintLogger.trace(
                    "failed write storage",
                    info: [
                        "error": error.localizedDescription,
                        "key": key,
                        "url": storageUrl.absoluteString,
                    ]
                )
                throw error
            }
        }
    }
    func readValue<T>(for key: String) throws -> T? where T: Decodable {
        do {
            let data = try Data(contentsOf: storageUrl)
            let decoded = try decoder.decode(Dictionary<String, Data>.self, from: data)
            let value = decoded[key]
            return try value.map { valueData -> T in
                do {
                    let value = try decoder.decode(T.self, from: valueData)
                    let description = (value as? CustomStringConvertible)?.description ?? "no description"
                    PrintLogger.trace("decoded \(type(of: value))", info: ["value": description])
                    return value
                } catch {
                    PrintLogger.trace("failed decoding", info: ["error": error.localizedDescription, "key": key])
                    throw error
                }
            }
        } catch {
            PrintLogger.error(error.localizedDescription)
            throw error
        }
    }
}
