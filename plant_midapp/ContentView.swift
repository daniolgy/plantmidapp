import SwiftUI

struct ContentView: View {
    @State private var setReminderSheet = false
    var body: some View {
        NavigationView {
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

                    
                       

                        
                    Rectangle() //divider
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 2) // set thickness here
                        .padding(.bottom, 70)


                    
                    Image("plant image") // name of your image asset
                        .resizable()
                           .scaledToFit()
                           .frame(width: 164, height: 200)
                       
                        .padding(.bottom, 30)
                    Text("Start your plant journey!")
                        .font(.system(size: 25, weight: .bold))
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
                                //.shadow(color: Color.white.opacity(1), radius: 0.25, x: 2, y: 2)
                        ) .glassEffect(.clear)
                }
                .sheet(isPresented: $setReminderSheet) {
                    ReminderView()
                }
                }

                    
                }
                .padding(.bottom, 150)
                        
                    }

                           }
            



        
#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
