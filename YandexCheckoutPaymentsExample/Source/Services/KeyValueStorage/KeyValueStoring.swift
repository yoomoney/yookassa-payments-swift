import Foundation

protocol KeyValueStoring {

    func setAny(_ value: Any?, for key: String)
    func getAny(for key: String) -> Any?

    func setBool(_ value: Bool?, for key: String)
    func getBool(for key: String) -> Bool?

    func setInt(_ value: Int?, for key: String)
    func getInt(for key: String) -> Int?

    func setString(_ value: String?, for key: String)
    func getString(for key: String) -> String?

    func setDecimal(_ value: Decimal?, for key: String)
    func getDecimal(for key: String) -> Decimal?
}
