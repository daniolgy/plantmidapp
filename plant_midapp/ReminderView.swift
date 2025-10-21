//
//  ReminderView.swift
//  plant_midapp
//
//  Created by Danah Aleyadhi on 20/10/2025.
//

import SwiftUI

struct ReminderView: View {
    
    
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
        NavigationView {
            VStack(spacing: 24) {
                // Plant Name Field
                TextField("Plant Name", text: $plantName)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    .padding(.horizontal)
                
                // Room & Light
                VStack(spacing: 12) {
                    PickerRow(title: "Room", selection: $selectedRoom, options: rooms)
                    PickerRow(title: "Light", selection: $selectedLight, options: lights)
                }
                .padding(.horizontal)
                
                // Watering Info
                VStack(spacing: 12) {
                    PickerRow(title: "Watering Days", selection: $selectedWatering, options: wateringDays)
                    PickerRow(title: "Water", selection: $selectedWaterAmount, options: waterAmounts)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top, 24)
            .navigationTitle("Set Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        // Save action
                    }) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor((Color(red: 92/255, green: 244/255, blue: 198/255)))
                    }
                }
            }
            .background(Color.black.ignoresSafeArea())
            .preferredColorScheme(.dark)
        }
    }
}

struct PickerRow: View {
    let title: String
    @Binding var selection: String
    let options: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Picker(selection: $selection, label: Label(title, systemImage: iconFor(title))) {
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            .pickerStyle(.menu)
            .tint(.gray)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    func iconFor(_ title: String) -> String {
        switch title {
        case "Room": return "paperplane"
        case "Light": return "sun.max"
        case "Watering Days", "Water": return "drop"
        default: return "circle"
        }
    }
}

#Preview {
    ReminderView()
}




