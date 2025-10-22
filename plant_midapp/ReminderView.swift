import SwiftUI

struct ReminderView: View {
    @State private var goToMainPage = false
    @Environment(\.dismiss) var dismiss
    
    @State private var plantName = ""
    @State private var selectedRoom = "Bedroom"
    @State private var selectedLight = "Full Sun"
    @State private var selectedWatering = "Every day"
    @State private var selectedWaterAmount = "20–50 ml"
    
    let rooms = ["Bedroom", "Living Room", "Kitchen", "Balcony", "Bathroom"]
    let lights = ["Full Sun", "Partial Sun", "Low Light"]
    let wateringDays = [
        "Every day", "Every 2 days", "Every 3 days",
        "Once a week", "Every 10 days", "Every 2 weeks"
    ]
    let waterAmounts = ["20–50 ml", "50–100 ml", "100–200 ml", "200–300 ml"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Plant Name
                HStack {
                    Text("Plant Name")
                        .foregroundColor(.white)
                    TextField("Pothos", text: $plantName)
                        .foregroundColor(.grayLightest)
                }
                .padding()
                .background(Color(.grayLight))
                .cornerRadius(30)
                .padding(.horizontal)
                
                // Room + Light
                VStack(spacing: 0) {
                    PickerRow(title: "Room", selection: $selectedRoom, options: rooms)
                    Divider().background(Color.gray.opacity(0.4)).padding(.horizontal)
                    PickerRow(title: "Light", selection: $selectedLight, options: lights)
                }
                .background(RoundedRectangle(cornerRadius: 30).fill(Color(.grayLight)))
                .padding(.horizontal)
                
                // Watering + Amount
                VStack(spacing: 0) {
                    PickerRow(title: "Watering Days", selection: $selectedWatering, options: wateringDays)
                    Divider().background(Color.gray.opacity(0.4)).padding(.horizontal)
                    PickerRow(title: "Water", selection: $selectedWaterAmount, options: waterAmounts)
                }
                .background(RoundedRectangle(cornerRadius: 30).fill(Color(.grayLight)))
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, 24)
            .navigationTitle("Set Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { goToMainPage = true }) {
                        Image(systemName: "checkmark")
                    }
                }
            }
            .background(Color.grayDark.ignoresSafeArea())
            .preferredColorScheme(.dark)
            // Navigate to MainPage
            .navigationDestination(isPresented: $goToMainPage) {
                mainPage()
            }
        }
    }
}

// MARK: - PickerRow
struct PickerRow: View {
    let title: String
    @Binding var selection: String
    let options: [String]
    
    var body: some View {
        HStack {
            Label(title, systemImage: iconFor(title))
                .foregroundColor(.white)
            Spacer()
            Menu {
                ForEach(options, id: \.self) { option in
                    Button(option) { selection = option }
                }
            } label: {
                HStack {
                    Text(selection).foregroundColor(Color(.grayLightest))
                    Image(systemName: "chevron.down").foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 14)
    }
    
    func iconFor(_ title: String) -> String {
        switch title {
        case "Room": return "paperplane"
        case "Light": return "sun.max"
        case "Watering Days": return "drop"
        case "Water": return "drop"
        default: return "circle"
        }
    }
}

// MARK: - Preview
#Preview {
    ReminderView()
}
