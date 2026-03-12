import Foundation
import SwiftUI
import Combine

enum QuotaStatus: String, CaseIterable {
    case ready = "READY"
    case pending = "PENDING"
    
    var color: Color {
        switch self {
        case .ready: return .green
        case .pending: return .gray
        }
    }
}

struct QuotaEntry: Identifiable, Codable {
    var id: UUID
    var email: String
    var resetDate: Date
    
    init(id: UUID = UUID(), email: String, resetDate: Date) {
        self.id = id
        self.email = email
        self.resetDate = resetDate
    }
    
    var status: QuotaStatus {
        return resetDate <= Date() ? .ready : .pending
    }
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: resetDate)
    }
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: resetDate)
    }
}

class QuotaStore: ObservableObject {
    @Published var entries: [QuotaEntry] = [] {
        didSet {
            save()
        }
    }
    
    private let saveKey = "SavedQuotaEntries"
    
    init() {
        load()
    }
    
    func addEntry(_ entry: QuotaEntry) {
        entries.insert(entry, at: 0)
    }
    
    func updateEntry(_ entry: QuotaEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
        }
    }
    
    func removeEntries(ids: Set<UUID>) {
        entries.removeAll { ids.contains($0.id) }
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([QuotaEntry].self, from: data) {
            self.entries = decoded
        } else {
            // Initial empty state (removed dummy data)
            self.entries = []
        }
    }
}
