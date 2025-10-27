//
//  plant_midappApp.swift
//  plant_midapp
//
//  Created by Danah Aleyadhi on 19/10/2025.
//

import SwiftUI
import UserNotifications
//


@main
struct PlantMidappApp: App {
    init() {
        // Let notifications show while app is open
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        NotificationManager.shared.requestAuthorization()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
