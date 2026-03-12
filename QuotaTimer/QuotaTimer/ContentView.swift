import SwiftUI
import Combine

struct ContentView: View {
    @StateObject private var store = QuotaStore()
    @State private var selectedFilter: String = "All Quotas"
    @State private var searchText: String = ""
    @State private var isShowingAddSheet = false
    @State private var selectedIds: Set<UUID> = []
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
                    
                    if !selectedIds.isEmpty {
                        Button(action: {
                            withAnimation(.easeInOut) {
                                store.removeEntries(ids: selectedIds)
                                selectedIds.removeAll()
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "trash.fill")
                                Text("Delete (\(selectedIds.count))")
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.red.opacity(0.2))
                            .foregroundColor(.red)
                            .cornerRadius(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                        .padding(.trailing, 8)
                    }
                    
                    Button(action: { isShowingAddSheet = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus")
                                .fontWeight(.bold)
                            Text("New Entry")
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                        .shadow(color: Color.blue.opacity(0.3), radius: 4, y: 2)
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
                    
                    // Select All Checkbox
                    Button(action: {
                        let currentIds = Set(filteredEntries.map { $0.id })
                        if selectedIds.intersection(currentIds).count == currentIds.count && !currentIds.isEmpty {
                            selectedIds.subtract(currentIds)
                        } else {
                            selectedIds.formUnion(currentIds)
                        }
                    }) {
                        Image(systemName: (selectedIds.intersection(Set(filteredEntries.map { $0.id })).count == filteredEntries.count && !filteredEntries.isEmpty) ? "checkmark.square.fill" : "square")
                            .foregroundColor(.secondary.opacity(0.8))
                            .font(.system(size: 14))
                    }
                    .buttonStyle(.plain)
                    .frame(width: 30, alignment: .center)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.02))
                
                // List
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(filteredEntries) { entry in
                            QuotaRow(
                                entry: entry,
                                isSelected: selectedIds.contains(entry.id),
                                onSelect: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        if selectedIds.contains(entry.id) {
                                            selectedIds.remove(entry.id)
                                        } else {
                                            selectedIds.insert(entry.id)
                                        }
                                    }
                                }
                            )
                            .contextMenu {
                                Button(role: .destructive) {
                                    withAnimation {
                                        store.removeEntries(ids: [entry.id])
                                        selectedIds.remove(entry.id)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
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
                    VStack(alignment: .leading, spacing: 2) {
                        Text("© ALL RIGHTS RESERVED TO RATHORE LLC ™")
                            .font(.system(size: 8, weight: .bold))
                            .kerning(1)
                            .foregroundColor(.secondary)
                        Text("Today at \(now.formatted(date: .omitted, time: .shortened))")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary.opacity(0.8))
                    }
                    Spacer()
                    Button(action: {
                        withAnimation {
                            now = Date()
                        }
                    }) {
                        Label("REFRESH", systemImage: "arrow.clockwise")
                            .font(.system(size: 10, weight: .bold))
                            .kerning(0.5)
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.blue)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 10)
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
    let isSelected: Bool
    let onSelect: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.email)
                    .font(.body)
                    .bold()
                    .foregroundColor(.white)
            }
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
            
            Button(action: onSelect) {
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(isSelected ? Color.blue : Color.secondary.opacity(0.3), lineWidth: 1.5)
                        .frame(width: 18, height: 18)
                        .background(isSelected ? Color.blue : Color.clear)
                        .cornerRadius(4)
                    
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .buttonStyle(.plain)
            .frame(width: 30, alignment: .center)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(isSelected ? Color.blue.opacity(0.05) : (isHovered ? Color.white.opacity(0.02) : Color.clear))
        .contentShape(Rectangle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
        .onTapGesture {
            onSelect()
        }
    }
}

#Preview {
    ContentView()
}
