import SwiftUI

struct MainPlantsView: View {
    @EnvironmentObject private var store: PlantStore
    @Binding var setReminderSheet: Bool

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    Text("My Plants 🌱")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.top, 20)
                .padding(.horizontal)

                Divider()
                    .background(Color.white)

                // Status
                Text(store.progress >= 1.0 ? "All set for today 🌟" : "Your plants are waiting for a sip 💦")
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .regular))
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .init(horizontal: .center, vertical: .center))

                // Progress bar
                ProgressView(value: store.progress)
                    .progressViewStyle(.linear)
                    .tint(Color(red: 92/255, green: 244/255, blue: 198/255))
                    .padding(.horizontal)
                
                // List of plants
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(store.plants) { plant in
                            PlantRow(plant: plant) {
                                withAnimation(.easeInOut) {
                                    store.toggleWatered(for: plant.id)
                                }
                            }
                            Divider()
                                .background(Color.white)
                        }
                    }
                    .padding(.top, 8)
                }

                Spacer()
            }
        }
        .overlay(alignment: .bottomTrailing) {
            Button {
                setReminderSheet = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 62, height: 62)
                    .background(
                        Circle().fill(Color(.greenPlant))
                    )
                    .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4)
            }
            .padding(.trailing, 24)
            .padding(.bottom, 24)
        }
        .preferredColorScheme(.dark)
        .background(Color.black)
    }
}

private struct PlantRow: View {
    let plant: Plant
    let onToggle: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Circular checkbox
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .strokeBorder(Color.white.opacity(0.6), lineWidth: 2)
                        .frame(width: 32, height: 32)
                    if plant.isWateredToday {
                        Circle()
                            .fill(Color(red: 92/255, green: 244/255, blue: 198/255))
                            .frame(width: 22, height: 22)
                    }
                }
            }
            .buttonStyle(.plain)
            .padding(.leading, 16)
            .padding(.top, 26)

            VStack(alignment: .leading, spacing: 8) {
                // Location line
                HStack(spacing: 6) {
                    Image(systemName: "paperplane")
                        .foregroundColor(.gray)
                        .font(.system(size: 15, weight: .regular))

                    Text("in \(plant.room)")
                        .foregroundColor(.gray)
                        .font(.system(size: 15, weight: .regular))
                }

                // Plant name
                Text(plant.name)
                    .foregroundColor(.white)
                    .font(.system(size: 28, weight: .regular))

                // Tags
                HStack(spacing: 12) {
                    // Sun tag (default yellow icon, neutral pill)
                    TagView(
                        icon: "sun.max",
                        text: plant.light
                    )
                    // Drop tag (custom aqua icon, aqua-tinted pill)
                    TagView(
                        icon: "drop",
                        text: plant.waterAmount,
                        iconColor: Color(.bluePlant),
                        textColor: .bluePlant,
                        backgroundColor: Color(.grayKindaDark)
                    )
                }
            }

            Spacer()
        }
        .padding(.vertical, 16)
    }
}

private struct TagView: View {
    let icon: String
    let text: String
    var iconColor: Color = Color(.goldPlant) // default for sun
    var textColor: Color = .goldPlant
    var backgroundColor: Color = Color.grayKindaDark

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
            Text(text)
                .foregroundColor(textColor)
                .font(.system(size: 14, weight: .regular))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 5)
        .background(backgroundColor)
        .clipShape(Capsule())
    }
}

#Preview {
    // Preview with sample data so you can open this view directly.
    let sampleStore = PlantStore()
    sampleStore.plants = [
        Plant(name: "Pothos", room: "Living Room", light: "Low Light", wateringDays: "Every 3 days", waterAmount: "50–100 ml"),
        Plant(name: "Snake Plant", room: "Bedroom", light: "Low Light", wateringDays: "Once a week", waterAmount: "20–50 ml", isWateredToday: true)
    ]
    return MainPlantsView(setReminderSheet: .constant(false))
        .environmentObject(sampleStore)
        .preferredColorScheme(.dark)
}
