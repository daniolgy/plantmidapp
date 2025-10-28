Plant Midapp

A simple, elegant iOS app that helps you remember to water your plants. Create reminders with predefined schedules and water amounts, and get notified at the exact time you set them up — every day, every few days, weekly, or biweekly.

• Platform: iOS (SwiftUI)
• Language: Swift
• Notifications: Local (UserNotifications)

Features

• Add plant reminders with:
   • Name
   • Room (Bedroom, Living Room, Kitchen, Balcony, Bathroom)
   • Light level (Full Sun, Partial Sun, Low Light)
   • Watering schedule (Every day, Every 2 days, Every 3 days, Once a week, Every 10 days, Every 2 weeks)
   • Water amount (20–50 ml, 50–100 ml, 100–200 ml, 200–300 ml)
• Notification timing anchored to when you create/edit the reminder:
   • Example: If you save at 3:26 PM and choose “Every day,” your next notification fires at 3:26 PM tomorrow.
• Foreground notifications (banners + sound) while the app is open.
• Progress view showing how many plants are marked as “watered today.”
• Edit and delete reminders.
• Test options:
   • “Every 10 seconds (test)” schedule in the UI (single fire).
   • Developer helpers: 60s repeating and 30s one-off test notifications.

How It Works

• Users pick from predefined options in ReminderView.
• When a plant is created or edited:
   • A notification is scheduled via NotificationManager.
   • Scheduling uses repeating time-interval triggers so the first fire time is anchored to the moment the user saved.
   • Examples:
      • Every day: repeats every 24 hours from save time.
      • Every 3 days: repeats every 3 × 24 hours from save time.
      • Once a week: repeats every 7 × 24 hours from save time.
      • Every 2 weeks: repeats every 14 × 24 hours from save time.
• Foreground display (banner + sound) is enabled by a notification delegate.

Project Structure (key files)

• plant_midappApp.swift􀰓
   • Sets UNUserNotificationCenter delegate.
   • Requests notification authorization at app launch.
• NotificationDelegate.swift􀰓
   • UNUserNotificationCenterDelegate to show banners/sounds in foreground.
• NotificationManager.swift􀰓
   • Requests authorization.
   • Schedules/cancels notifications.
   • Parses user-chosen schedule strings.
   • Uses UNTimeIntervalNotificationTrigger so timing starts from when the user saves.
• PlantStore.swift􀰓
   • Plant model.
   • In-memory store for plants and progress.
   • Schedules notifications on add; cancels on delete.
• ReminderView.swift􀰓
   • UI to create/edit a plant reminder.
   • Predefined pickers for schedule and water amount.
   • Calls into PlantStore/NotificationManager on save.
• MainPlantsView.swift􀰓
   • Displays your plants and progress.
   • Mark plants as watered today.
   • Edit or delete reminders.

Notifications

• Permission is requested at app launch.
• Foreground notifications (when the app is open) show as banners with sound via NotificationDelegate.
• Identifiers are namespaced per plant (UUID) for reliable cancellation and rescheduling.
• Notes:
   • Repeating time-interval triggers are used for all schedules to anchor to “now.”
   • Around DST transitions, interval-based schedules may appear to shift by an hour. If you need strict local clock time across DST, you’d switch to calendar-based triggers and store a specific time.

Requirements

• iOS target that supports UserNotifications and SwiftUI (iOS 15+ recommended).
• Xcode 15+ recommended.

Getting Started

1. Open the project in Xcode.
2. Run on a device or simulator.
3. On first launch, allow notifications.
4. Tap the + button to add a plant:
   • Enter a name, room, light level, watering schedule, and water amount.
   • Tap the checkmark to save.
5. You’ll receive notifications based on the schedule, anchored to the save time.

Editing and Deleting

• Tap a plant in the list to edit.
• Changes reschedule notifications immediately.
• Swipe to delete removes the plant and cancels its pending notifications.

Testing Notifications

• In ReminderView’s schedule options, pick “Every 10 seconds (test)” to quickly verify a one-off notification.
• Developer helpers (in NotificationManager):
   • scheduleRepeatingTestNotificationEvery60Seconds()
   • scheduleOneOffTestNotificationIn30Seconds()

Localization

• Notification text and UI labels are currently in English. Add Localizable.strings to support more languages.

Privacy

• The app uses local notifications only. No data leaves the device.

Roadmap / Ideas

• Time picker for choosing a specific time of day (and switch to calendar triggers).
• Weekday picker for weekly schedules aligned to a specific day.
• Interactive notification actions (e.g., “Mark as watered”).
• Persistent storage (e.g., SwiftData/Core Data) for plants.
• Badges (currently permission requested but badge values not set).

Troubleshooting

• Not receiving notifications:
   • Ensure notifications are allowed in Settings.
   • The app must be in foreground to see banners (handled by NotificationDelegate).
   • The device may coalesce notifications for power saving; they should still arrive close to the expected time.
• Foreground banners not showing:
   • Make sure NotificationDelegate is set as UNUserNotificationCenter.current().delegate at app launch.
• Changed schedule not reflected:
   • Editing a plant reschedules notifications. Confirm the edit flow completed.
