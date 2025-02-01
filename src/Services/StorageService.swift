import Foundation

@MainActor
public final class StorageService: ObservableObject {
    public static let shared = StorageService()
    
    @Published public private(set) var isLoading = false
    @Published public private(set) var error: Error?
    
    private let baseURL = "https://adventisthymnarium.rockvilletollandsda.church"
    
    private init() {}
    
    public func downloadAsset(path: String) async throws -> Data {
        // Clean up any double slashes in the path
        let cleanPath = path.replacingOccurrences(of: "//", with: "/")
        guard let url = URL(string: "\(baseURL)/\(cleanPath)") else {
            throw NSError(domain: "StorageService", code: -1, 
                         userInfo: [NSLocalizedDescriptionKey: "Invalid URL path"])
        }
        
        print("Downloading from URL: \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NSError(domain: "StorageService", code: -1, 
                            userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
            }
            
            guard httpResponse.statusCode == 200 else {
                var errorMessage = "Failed to download asset: \(httpResponse.statusCode)"
                if let errorString = String(data: data, encoding: .utf8) {
                    errorMessage += " - \(errorString)"
                }
                throw NSError(domain: "StorageService", code: httpResponse.statusCode, 
                            userInfo: [NSLocalizedDescriptionKey: errorMessage])
            }
            
            return data
        } catch {
            print("Network error: \(error.localizedDescription)")
            throw NSError(domain: "StorageService", code: -1, 
                         userInfo: [NSLocalizedDescriptionKey: "Failed to download asset: \(error.localizedDescription)"])
        }
    }
    
    public func getAssetURL(path: String) -> URL? {
        let cleanPath = path.replacingOccurrences(of: "//", with: "/")
        return URL(string: "\(baseURL)/\(cleanPath)")
    }
} 