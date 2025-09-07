import Foundation
import Combine

@MainActor
class QuipManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var documents: [QuipDocument] = []
    @Published var lastSyncDate: Date?
    
    private var apiToken: String?
    private let baseURL = "https://platform.quip.com/1"
    
    func authenticate(token: String) async {
        self.apiToken = token
        await validateToken()
    }
    
    private func validateToken() async {
        guard let token = apiToken else { return }
        
        var request = URLRequest(url: URL(string: "\(baseURL)/users/current")!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                isAuthenticated = httpResponse.statusCode == 200
                if isAuthenticated {
                    saveCredentials()
                }
            }
        } catch {
            print("Quip authentication failed: \(error)")
            isAuthenticated = false
        }
    }
    
    func syncDocuments() async {
        guard isAuthenticated, let token = apiToken else { return }
        
        var request = URLRequest(url: URL(string: "\(baseURL)/folders/")!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(QuipFoldersResponse.self, from: data)
            
            var allDocuments: [QuipDocument] = []
            
            for (_, folder) in response {
                if let children = folder.children {
                    for child in children {
                        if child.contains("document") {
                            if let doc = await fetchDocument(id: child, token: token) {
                                allDocuments.append(doc)
                            }
                        }
                    }
                }
            }
            
            documents = allDocuments
            lastSyncDate = Date()
        } catch {
            print("Quip sync failed: \(error)")
        }
    }
    
    private func fetchDocument(id: String, token: String) async -> QuipDocument? {
        var request = URLRequest(url: URL(string: "\(baseURL)/threads/\(id)")!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let doc = try JSONDecoder().decode(QuipDocument.self, from: data)
            return doc
        } catch {
            print("Failed to fetch document \(id): \(error)")
            return nil
        }
    }
    
    func getActionableItems() -> [IntegratedItem] {
        return documents.compactMap { doc in
            if doc.title.lowercased().contains("todo") || 
               doc.title.lowercased().contains("action") ||
               doc.title.lowercased().contains("task") {
                return IntegratedItem(
                    id: doc.id,
                    title: "Quip: \(doc.title)",
                    description: "Review document and complete actions",
                    priority: .medium,
                    dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()),
                    url: doc.link,
                    source: "Quip Document",
                    createdAt: Date(timeIntervalSince1970: doc.createdUsec / 1000000)
                )
            }
            return nil
        }
    }
    
    func saveCredentials() {
        if let token = apiToken {
            UserDefaults.standard.set(token, forKey: "quip_token")
        }
    }
    
    func loadCredentials() {
        if let token = UserDefaults.standard.string(forKey: "quip_token") {
            self.apiToken = token
            Task {
                await validateToken()
            }
        }
    }
    
    func logout() {
        apiToken = nil
        isAuthenticated = false
        documents = []
        UserDefaults.standard.removeObject(forKey: "quip_token")
    }
}

struct QuipDocument: Codable, Identifiable {
    let id: String
    let title: String
    let link: String
    let createdUsec: TimeInterval
    let updatedUsec: TimeInterval
}

typealias QuipFoldersResponse = [String: QuipFolder]

struct QuipFolder: Codable {
    let title: String
    let children: [String]?
}