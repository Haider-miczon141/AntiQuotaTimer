import SwiftUI
import Combine

struct ContentView: View {
    @StateObject private var store = QuotaStore()
    @State private var selectedFilter: String = "All Quotas"
    @State private var searchText: String = ""
    @State private var isShowingAddSheet = false
    @State private var now = Date()
    
    let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    
    // Background Colors
    let sidebarBg = Color(red: 30/255, green: 30/255, blue: 30/255)
    let contentBg = Color(red: 20/255, green: 20/255, blue: 20/255)
    let cardBg = Color(red: 25/255, green: 25/255, blue: 25/255)
    let borderColor = Color.white.opacity(0.1)
    
    var filteredEntries: [QuotaEntry] {
        store.entries.filter { entry in
            let matchesSearch = searchText.isEmpty || entry.email.localizedCaseInsensitiveContains(searchText)
            if !matchesSearch { return false }
            
            switch selectedFilter {
            case "Ready": return entry.status == .ready
            case "Pending": return entry.status == .pending
            default: return true
            }
        }
    }
    
    var body: some View {
        NavigationSplitView {
            // Sidebar
            List(selection: $selectedFilter) {
                Section {
                    SidebarItem(title: "All Quotas", icon: "list.bullet.indent", selection: $selectedFilter)
                    SidebarItem(title: "Ready", icon: "checkmark.circle.fill", iconColor: .green, selection: $selectedFilter)
                    SidebarItem(title: "Pending", icon: "clock.fill", iconColor: .gray, selection: $selectedFilter)
                }
            }
            .listStyle(.sidebar)
            .navigationSplitViewColumnWidth(min: 200, ideal: 240)
            .background(sidebarBg)
        } detail: {
            // Main Content
            VStack(spacing: 0) {
                // Header
                HStack(alignment: .center) {
                    Text("Quota Resets")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search emails...", text: $searchText)
                            .textFieldStyle(.plain)
                            .frame(width: 200)
                            .foregroundColor(.white)
                    }
                    .padding(6)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(borderColor, lineWidth: 1)
                    )
                    
                    Button(action: { isShowingAddSheet = true }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("New Entry")
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }
                .padding()
                
                Divider()
                    .background(borderColor)
                
                // Table Header
                HStack {
                    Text("USER / EMAIL")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("SCHEDULED DATE")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 150, alignment: .leading)
                    Text("TIME")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 100, alignment: .leading)
                    Text("STATUS")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 100, alignment: .center)
                    Spacer()
                        .frame(width: 20)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.02))
                
                // List
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(filteredEntries) { entry in
                            QuotaRow(entry: entry)
                            Divider()
                                .background(borderColor)
                                .padding(.horizontal)
                        }
                    }
                }
                
                Spacer()
                
                // Footer
                Divider()
                    .background(borderColor)
                HStack {
                    VStack(alignment: .leading) {
                        Text("LAST UPDATED")
                            .font(.system(size: 8))
                            .foregroundColor(.secondary)
                        Text("Today at \(now.formatted(date: .omitted, time: .shortened))")
                            .font(.caption2)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Button(action: {}) {
                        Label("Refresh", systemImage: "arrow.clockwise")
                            .font(.caption)
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.blue)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(contentBg)
            }
            .background(contentBg)
            .onReceive(timer) { input in
                now = input
            }
        }
        .sheet(isPresented: $isShowingAddSheet) {
            AddQuotaView(store: store)
        }
    }
}

struct SidebarItem: View {
    let title: String
    let icon: String
    var iconColor: Color = .blue
    @Binding var selection: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .frame(width: 18)
            Text(title)
                .foregroundColor(.white)
        }
        .tag(title)
    }
}

struct QuotaRow: View {
    let entry: QuotaEntry
    
    var body: some View {
        HStack {
            Text(entry.email)
                .font(.body)
                .bold()
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(entry.dateString)
                .font(.body)
                .foregroundColor(.secondary)
                .frame(width: 150, alignment: .leading)
            
            Text(entry.timeString)
                .font(.body)
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .leading)
            
            Text(entry.status.rawValue)
                .font(.system(size: 10, weight: .bold))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(entry.status.color.opacity(0.15))
                .foregroundColor(entry.status.color)
                .cornerRadius(4)
                .frame(width: 100, alignment: .center)
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary.opacity(0.5))
                .font(.caption)
                .frame(width: 20)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .contentShape(Rectangle())
    }
}

#Preview {
    ContentView()
}
