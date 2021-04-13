import ThreatMetrixAdapter

enum ThreatMetrixServiceFactory {
    static func makeService() -> ThreatMetrixService {
        let threatMetrixService: ThreatMetrixService
        do {
            threatMetrixService = try ThreatMetrixAdapter
                .ThreatMetrixServiceFactory
                .makeService(configuration: .default)
        } catch {
            fatalError(error.localizedDescription)
        }
        return threatMetrixService
    }
}
