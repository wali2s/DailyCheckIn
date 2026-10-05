# DailyCheckIn

DailyCheckIn is a private, local-first iOS journaling app for short daily reflections.

It helps users pause for a moment, check in with themselves, track patterns over time, and build healthier routines.

## Features

- One daily check-in for both Personal and Work life
- Mood selection:
  - Calm
  - Good
  - Happy
  - Neutral
  - Low
  - Tense
- Personal notes and tags
- Track energy, stress, focus, social battery, and physical comfort
- Create recurring activities:
  - Daily
  - Weekly
  - Monthly
- Activity reminders
- Calendar-based history for Personal and Work check-ins
- Statistics and mood/activity patterns
- Edit and delete check-ins safely
- Local backup, export, import, merge, and restore
- Automatic local safety backups
- App lock with Face ID, Touch ID, or device passcode
- Optional “Dein CheckIn Rewards” pilot concept

## Privacy

DailyCheckIn is designed with privacy in mind.

- Check-ins, notes, moods, and activities are stored locally on the device.
- Personal journal data is separate from the optional rewards concept.
- Rewards must never depend on mood, notes, energy, or other personal check-in data.
- Users can export their data as a JSON backup.
- Users can import a previous backup and choose to merge or replace data.

> Automatic safety backups are currently stored inside the app’s local storage.  
> Before deleting the app or changing devices, users should export a backup manually.

## Tech Stack

- Swift
- SwiftUI
- MVVM architecture
- Combine
- UserDefaults for local structured data
- FileManager for local safety backups
- UserNotifications for reminders
- LocalAuthentication for Face ID, Touch ID, and device passcode protection

## Project Structure

```text
DailyCheckIn
├── App
├── Models
├── Services
├── UI
├── ViewModels
└── Views


Running the Project
1. Clone this repository.
2. Open DailyCheckIn.xcodeproj in Xcode.
3. Select an iPhone simulator or physical iPhone.
4. Build and run the DailyCheckIn target.
Testing
The project includes unit tests and UI tests.
Cmd + U
Use a dedicated simulator for UI tests. UI tests intentionally reset local data to guarantee a clean test state.
Roadmap
- Daily Personal and Work check-ins
- Activities and reminders
- Calendar history
- Statistics
- Import, export, and local safety backups
- Face ID / device passcode protection
- Dein CheckIn Rewards UI prototype
- Optional private iCloud safety backup
- Full localization
- AI-powered daily, weekly, and monthly insights for Prime members
- Secure QR-based rewards validation for the Dein CheckIn coffee pilot
Dein CheckIn Concept
DailyCheckIn is also the foundation for a future coffee-to-go concept called Dein CheckIn.
The idea is simple:
Take a short moment for yourself — with a good drink.

The app remains a personal reflection tool. A future optional rewards area may allow customers to collect points after purchases at a Dein CheckIn coffee stand.
Status
DailyCheckIn is currently in active development and is not yet released on the App Store.
