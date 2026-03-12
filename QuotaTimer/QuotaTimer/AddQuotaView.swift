import SwiftUI
import Combine

struct AddQuotaView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var store: QuotaStore
    var editingEntry: QuotaEntry? = nil
    
    @State private var email: String = ""
    @State private var dateString: String = "12/03/2026"
    @State private var timeString: String = "14:53:58"
    @State private var showError = false
    
    // Theme Colors
    let contentBg = Color(red: 35/255, green: 35/255, blue: 35/255)
    let borderColor = Color.white.opacity(0.1)
    
    var isFormValid: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        !dateString.trimmingCharacters(in: .whitespaces).isEmpty &&
        !timeString.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Title bar
            HStack {
                Spacer()
                Text(editingEntry == nil ? "Manual Entry - Quota Reset" : "Update Entry - Quota Reset")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.vertical, 8)
            .background(Color.black.opacity(0.3))
            
            Divider()
                .background(borderColor)
            
            // Form Content
            VStack(alignment: .leading, spacing: 25) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(editingEntry == nil ? "Log Reset Event" : "Update Reset Event")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                    Text(editingEntry == nil ? "Enter the details for the manual quota refresh cycle." : "Modify the existing quota reset details.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 10)
                
                VStack(alignment: .leading, spacing: 20) {
                    // User Email Address
                    HStack {
                        Text("User Email Address")
                            .font(.body)
                            .foregroundColor(.white)
                            .frame(width: 150, alignment: .trailing)
                        TextField("user@example.com", text: $email)
                            .textFieldStyle(.plain)
                            .padding(8)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(6)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(borderColor, lineWidth: 1))
                            .foregroundColor(.white)
                    }
                    
                    // Reset Date
                    HStack {
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Reset Date")
                                .font(.body)
                                .foregroundColor(.white)
                                .frame(width: 150, alignment: .trailing)
                            Text("Format: D/MM/YYYY (e.g., 12/03/2026)")
                                .font(.system(size: 9))
                                .foregroundColor(.secondary)
                        }
                        TextField("12/03/2026", text: $dateString)
                            .textFieldStyle(.plain)
                            .padding(8)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(6)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(borderColor, lineWidth: 1))
                            .foregroundColor(.white)
                    }
                    
                    // Reset Time
                    HStack {
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Reset Time")
                                .font(.body)
                                .foregroundColor(.white)
                                .frame(width: 150, alignment: .trailing)
                            Text("Format: 24h (HH:MM:SS)")
                                .font(.system(size: 9))
                                .foregroundColor(.secondary)
                        }
                        TextField("14:53:58", text: $timeString)
                            .textFieldStyle(.plain)
                            .padding(8)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(6)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(borderColor, lineWidth: 1))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                HStack {
                    if showError {
                        Text("Invalid format. Use D/MM/YYYY and HH:MM:SS")
                            .font(.caption2)
                            .foregroundColor(.red)
                    } else if !isFormValid && (!email.isEmpty || !dateString.isEmpty || !timeString.isEmpty) {
                        Text("All fields are required")
                            .font(.caption2)
                            .foregroundColor(.orange.opacity(0.8))
                    }
                    Spacer()
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.1))
                    .foregroundColor(.white)
                    .cornerRadius(6)
                    
                    Button(editingEntry == nil ? "Save Entry" : "Update Entry") {
                        saveEntry()
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(isFormValid ? Color.blue : Color.gray.opacity(0.3))
                    .foregroundColor(isFormValid ? .white : .white.opacity(0.5))
                    .cornerRadius(6)
                    .padding(.leading, 8)
                    .disabled(!isFormValid)
                }
                .padding(.top, 20)
            }
            .padding(40)
            .background(contentBg)
            
            Divider()
                .background(borderColor)
            
            // Footer
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "copyright")
                    Text("© ALL RIGHTS RESERVED TO RATHORE LLC ™")
                        .fontWeight(.bold)
                        .kerning(1)
                }
                .font(.system(size: 8))
                .foregroundColor(.secondary)
                
                Spacer()
                
                Text("SECURE SYSTEM")
                    .font(.system(size: 8, weight: .bold))
                    .kerning(1)
                    .foregroundColor(.secondary.opacity(0.6))
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.4))
        }
        .frame(width: 600, height: 500)
        .preferredColorScheme(.dark)
        .onAppear {
            if let entry = editingEntry {
                email = entry.email
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "d/MM/yyyy"
                dateString = dateFormatter.string(from: entry.resetDate)
                
                let timeFormatter = DateFormatter()
                timeFormatter.locale = Locale(identifier: "en_US_POSIX")
                timeFormatter.dateFormat = "HH:mm:ss"
                timeString = timeFormatter.string(from: entry.resetDate)
            }
        }
    }
    
    func saveEntry() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        let formats = [
            "d/MM/yyyy HH:mm:ss",
            "dd/MM/yyyy HH:mm:ss",
            "d/M/yyyy HH:mm:ss",
            "dd/M/yyyy HH:mm:ss",
            "d/MM/yy HH:mm:ss"
        ]
        
        let cleanedDate = dateString.trimmingCharacters(in: .whitespaces)
        let cleanedTime = timeString.trimmingCharacters(in: .whitespaces)
        let combined = "\(cleanedDate) \(cleanedTime)"
        
        var parsedDate: Date? = nil
        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: combined) {
                parsedDate = date
                break
            }
        }
        
        if let date = parsedDate {
            if let existing = editingEntry {
                let updatedEntry = QuotaEntry(id: existing.id, email: email.trimmingCharacters(in: .whitespaces), resetDate: date)
                DispatchQueue.main.async {
                    store.updateEntry(updatedEntry)
                    dismiss()
                }
            } else {
                let newEntry = QuotaEntry(email: email.trimmingCharacters(in: .whitespaces), resetDate: date)
                DispatchQueue.main.async {
                    store.addEntry(newEntry)
                    dismiss()
                }
            }
        } else {
            withAnimation {
                showError = true
            }
        }
    }
}
