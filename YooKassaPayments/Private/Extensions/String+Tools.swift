extension String {
    func base64Encoded() -> String {
        guard let data = data(using: .utf8) else {
            return self
        }
        return data.base64EncodedString()
    }
}
