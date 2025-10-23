import SwiftUI

struct ContentView: View {
    @StateObject private var store = PlantStore()

    @State private var setReminderSheet = false
    @State private var hasCompletedSetup = false

    var body: some View {
        NavigationView {
            Group {
                if hasCompletedSetup {
                    MainPlantsView(setReminderSheet: $setReminderSheet)
                        .environmentObject(store)
                } else {
                    // SPLASH PAGE
                    VStack {
                        VStack(spacing: 10) {
                            HStack {
                                Text("My Plants 🌱")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .padding(.top, 20)
                            .padding(.bottom, 7)
                            .padding(.trailing, 200)

                            Rectangle()
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 2)
                                .padding(.bottom, 70)

                            Image("plant image")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 164, height: 200)
                                .padding(.bottom, 30)

                            Text("Start your plant journey!")
                                .font(.system(size: 25, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.bottom, 20)

                            Text("Now all your plants will be in one place and we will help you take care of them :)🪴")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(Color(Color(red: 159/255, green: 159/255, blue: 145/255)))
                                .multilineTextAlignment(.center)
                                .frame(width: 315, height: 40)
                                .padding(.bottom, 80)
                        }
                        Button(action: {
                            setReminderSheet = true
                        }) {
                            Text("Set Plant Reminder")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 280, height: 44)
                                .background(
                                    RoundedRectangle(cornerRadius: 1000)
                                        .fill(Color(red: 92/255, green: 244/255, blue: 198/255))
                                )
                                .glassEffect(.clear)
                        }
                    }
                    // Move the bottom padding so it only affects the splash page
                    .padding(.bottom, 150)
                }
            }
        }
        .sheet(isPresented: $setReminderSheet, onDismiss: {
            // Show main page once the first plant is added
            if !store.plants.isEmpty {
                hasCompletedSetup = true
            }
        }) {
            ReminderView()
                .environmentObject(store)
        }
        .preferredColorScheme(.dark)
        .background(Color.black)
        // Remove the global bottom padding here (was causing the checkmark to appear higher)
        // .padding(.bottom, 150)
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
