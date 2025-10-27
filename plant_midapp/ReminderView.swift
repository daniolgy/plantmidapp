import SwiftUI

enum ReminderMode {
    case create
    case edit(existing: Plant)
}

struct ReminderView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: PlantStore

    // Mode controls whether we create or edit
    let mode: ReminderMode

    @State private var plantName = ""
    @State private var selectedRoom = "Bedroom"
    @State private var selectedLight = "Full Sun"
    @State private var selectedWatering = "Every day"
    @State private var selectedWaterAmount = "20–50 ml"

    let rooms = ["Bedroom", "Living Room", "Kitchen", "Balcony", "Bathroom"]
    let lights = ["Full Sun", "Partial Sun", "Low Light"]
    let wateringDays = [
        "Every day",
        "Every 2 days",
        "Every 3 days",
        "Once a week",
        "Every 10 days",
        "Every 2 weeks",
        "Every 10 seconds (test)" // Added test option
    ]
    let waterAmounts = ["20–50 ml", "50–100 ml", "100–200 ml", "200–300 ml"]

    var nameIsValid: Bool {
        !plantName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    init(mode: ReminderMode = .create) {
        self.mode = mode
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Plant Name
                HStack {
                    Text("Plant Name")
                        .foregroundColor(.white)
                    TextField("Pothos", text: $plantName)
                        .foregroundColor(.grayLightest)
                        .submitLabel(.done)
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

                // Delete button only in edit mode
                if case let .edit(existing) = mode {
                    Button(role: .destructive) {
                        store.removePlant(id: existing.id)
                        dismiss()
                    } label: {
                        Text("Delete Reminder")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.red)
                            .frame(width: 370, height: 52) // exact size
                            .background(
                                Capsule().fill(Color.grayLight)
                            )
                    }
                    // remove horizontal padding so visual width is exactly 370
                    .padding(.top, 8)
                }

                Spacer()
            }
            .padding(.top, 24)
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: saveAndDismiss) {
                        Image(systemName: "checkmark")
                    }
                    .disabled(!nameIsValid)
                    .opacity(nameIsValid ? 1.0 : 0.4)
                }
            }
            .background(Color.grayDark.ignoresSafeArea())
            .preferredColorScheme(.dark)
            .onAppear(perform: populateIfEditing)
        }
    }

    private var navigationTitle: String {
        switch mode {
        case .create: return "Set Reminder"
        case .edit: return "Edit Reminder"
        }
    }

    private func populateIfEditing() {
        if case let .edit(existing) = mode {
            plantName = existing.name
            selectedRoom = existing.room
            selectedLight = existing.light
            selectedWatering = existing.wateringDays
            selectedWaterAmount = existing.waterAmount
        }
    }

    private func saveAndDismiss() {
        guard nameIsValid else { return }
        let trimmedName = plantName.trimmingCharacters(in: .whitespacesAndNewlines)

        switch mode {
        case .create:
            let newPlant = Plant(
                name: trimmedName,
                room: selectedRoom,
                light: selectedLight,
                wateringDays: selectedWatering,
                waterAmount: selectedWaterAmount
            )
            store.add(newPlant) // schedules notifications via PlantStore.add

        case .edit(let existing):
            // Update the existing plant in-place
            if let idx = store.plants.firstIndex(where: { $0.id == existing.id }) {
                var updated = store.plants[idx]
                updated.name = trimmedName
                updated.room = selectedRoom
                updated.light = selectedLight
                updated.wateringDays = selectedWatering
                updated.waterAmount = selectedWaterAmount
                store.plants[idx] = updated

                // Re-schedule notifications for the updated plant
                NotificationManager.shared.scheduleNotifications(for: updated, at: 9, minute: 0)
            }
        }

        dismiss()
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
    ReminderView(mode: .create)
        .environmentObject(PlantStore())
}
