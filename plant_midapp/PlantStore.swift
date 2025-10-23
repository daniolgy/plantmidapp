import Foundation
import Combine

struct Plant: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var room: String
    var light: String
    var wateringDays: String   // keep as display text for now (e.g., "Every 2 days")
    var waterAmount: String    // e.g., "20–50 ml"
    var isWateredToday: Bool

    init(id: UUID = UUID(),
         name: String,
         room: String,
         light: String,
         wateringDays: String,
         waterAmount: String,
         isWateredToday: Bool = false) {
        self.id = id
        self.name = name
        self.room = room
        self.light = light
        self.wateringDays = wateringDays
        self.waterAmount = waterAmount
        self.isWateredToday = isWateredToday
    }
}

final class PlantStore: ObservableObject {
    @Published var plants: [Plant] = []

    // Progress: 0.0 ... 1.0
    var progress: Double {
        guard !plants.isEmpty else { return 0 }
        let watered = plants.filter { $0.isWateredToday }.count
        return Double(watered) / Double(plants.count)
    }

    func add(_ plant: Plant) {
        plants.append(plant)
    }

    func toggleWatered(for plantID: UUID) {
        guard let idx = plants.firstIndex(where: { $0.id == plantID }) else { return }
        plants[idx].isWateredToday.toggle()
    }

    // Optional: call this at midnight if you want to reset daily state
    func resetTodayWatering() {
        for i in plants.indices {
            plants[i].isWateredToday = false
        }
    }
}
