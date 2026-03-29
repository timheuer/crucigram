import SwiftUI

/// Settings and about screen.
struct SettingsView: View {
  @AppStorage("dailyReminderEnabled") private var dailyReminderEnabled = true
  @State private var notificationDenied = false

  private var appVersion: String {
    let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    return "\(version)(\(build))"
  }

  private let privacyPolicyURL = URL(string: "https://timheuer.github.io/crucigram/privacy/")

  var body: some View {
    List {
      Section {
        Toggle("Daily Puzzle Reminder", isOn: $dailyReminderEnabled)
          .onChange(of: dailyReminderEnabled) { _, enabled in
            handleReminderToggle(enabled: enabled)
          }
      } header: {
        Text("Notifications")
      } footer: {
        if notificationDenied {
          Text(
            "Notifications are disabled in system settings. Open Settings → Crucigram → Notifications to enable them."
          )
        } else {
          Text("Get a reminder at 6 PM if you haven't completed the daily puzzle.")
        }
      }

      Section("About") {
        LabeledContent("Version", value: appVersion)

        if let url = privacyPolicyURL {
          Link(destination: url) {
            HStack {
              Text("Privacy Policy")
              Spacer()
              Image(systemName: "arrow.up.right.square")
                .font(.caption)
                .foregroundStyle(.secondary)
            }
          }
        }
      }

      Section("Acknowledgments") {
        NavigationLink("Open Source Licenses") {
          AcknowledgmentsView()
        }
      }
    }
    .navigationTitle("Settings")
    .onAppear {
      // Sync toggle state with actual system permission.
      Task {
        let authorized = await NotificationService.shared.isAuthorized()
        await MainActor.run {
          if !authorized && dailyReminderEnabled {
            notificationDenied = true
          } else {
            notificationDenied = false
          }
        }
      }
    }
  }

  private func handleReminderToggle(enabled: Bool) {
    if enabled {
      Task {
        let granted = await NotificationService.shared.requestPermission()
        await MainActor.run {
          if granted {
            notificationDenied = false
            let stats = PersistenceService.shared.loadPlayerStats()
            Task {
              _ = await NotificationService.shared.scheduleDailyReminderIfNeeded(stats: stats)
            }
          } else {
            notificationDenied = true
            dailyReminderEnabled = false
          }
        }
      }
    } else {
      NotificationService.shared.cancelDailyReminder()
      notificationDenied = false
    }
  }
}

#Preview {
  NavigationStack {
    SettingsView()
  }
}
