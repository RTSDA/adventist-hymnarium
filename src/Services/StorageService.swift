import Foundation

public struct Config: Codable {
    public let apiKeys: APIKeys
    
    public init(apiKeys: APIKeys) {
        self.apiKeys = apiKeys
    }
}

public struct APIKeys: Codable {
    public let r2AccessKeyId: String
    public let r2SecretAccessKey: String
    public let r2Endpoint: String
    public let r2Bucket: String
    
    public init(r2AccessKeyId: String, r2SecretAccessKey: String, r2Endpoint: String, r2Bucket: String) {
        self.r2AccessKeyId = r2AccessKeyId
        self.r2SecretAccessKey = r2SecretAccessKey
        self.r2Endpoint = r2Endpoint
        self.r2Bucket = r2Bucket
    }
}

@MainActor
public final class StorageService: ObservableObject {
    public static let shared = StorageService()
    
    @Published public private(set) var isLoading = false
    @Published public private(set) var error: Error?
    
    private var config: Config?
    private let baseURL = "https://pocketbase.hymnarium.app/api/collections/config/records"
    
    private init() {
        Task {
            await loadConfig()
        }
    }
    
    private func loadConfig() async {
        do {
            let url = URL(string: baseURL)!
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(PocketBaseResponse.self, from: data)
            if let config = response.items.first {
                self.config = config
            }
        } catch {
            self.error = error
        }
    }
    
    public func downloadAsset(path: String) async throws -> Data {
        guard let config = config else {
            throw NSError(domain: "StorageService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Configuration not loaded"])
        }
        
        let url = URL(string: "\(config.apiKeys.r2Endpoint)/\(config.apiKeys.r2Bucket)/\(path)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
    
    public func getAssetURL(path: String) -> URL? {
        guard let config = config else { return nil }
        return URL(string: "\(config.apiKeys.r2Endpoint)/\(config.apiKeys.r2Bucket)/\(path)")
    }
}

public struct PocketBaseResponse: Codable {
    public let items: [Config]
    
    public init(items: [Config]) {
        self.items = items
    }
} 