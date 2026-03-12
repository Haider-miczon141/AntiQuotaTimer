import SwiftUI
import Combine

struct AddQuotaView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var store: QuotaStore
    
    @State private var email: String = ""
    @State private var dateString: String = "12/3/2026"
    @State private var timeString: String = "14:53:58"
    @State private var showError = false
    
    // Theme Colors
    let contentBg = Color(red: 35/255, green: 35/255, blue: 35/255)
    let borderColor = Color.white.opacity(0.1)
    
    var body: some View {
        VStack(spacing: 0) {
            // Title bar
            HStack {
                Spacer()
                Text("Manual Entry - Quota Reset")
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
                    Text("Log Reset Event")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                    Text("Enter the details for the manual quota refresh cycle.")
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
                            Text("Format: MM/D/YYYY (e.g., 12/3/2026)")
                                .font(.system(size: 9))
                                .foregroundColor(.secondary)
                        }
                        TextField("12/3/2026", text: $dateString)
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
                        Text("Invalid format. Use MM/D/YYYY and HH:MM:SS")
                            .font(.caption2)
                            .foregroundColor(.red)
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
                    
                    Button("Save Entry") {
                        saveEntry()
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(6)
                    .padding(.leading, 8)
                }
                .padding(.top, 20)
            }
            .padding(40)
            .background(contentBg)
            
            Divider()
                .background(borderColor)
            
            // Footer
            HStack {
                Image(systemName: "square.on.square")
                    .foregroundColor(.secondary)
                Text("SYSTEM MONITOR V2.4")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)
                    Text("All Systems Operational")
                        .font(.caption2)
                        .italic()
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.black.opacity(0.3))
        }
        .frame(width: 600, height: 500)
        .preferredColorScheme(.dark)
    }
    
    func saveEntry() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        let formats = [
            "MM/d/yyyy HH:mm:ss",
            "M/d/yyyy HH:mm:ss",
            "MM/dd/yyyy HH:mm:ss",
            "M/d/yy HH:mm:ss",
            "MM/dd/yy HH:mm:ss"
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
            let newEntry = QuotaEntry(email: email.isEmpty ? "unknown@example.com" : email, resetDate: date)
            DispatchQueue.main.async {
                store.addEntry(newEntry)
                dismiss()
            }
        } else {
            withAnimation {
                showError = true
            }
        }
    }
}
