import SwiftUI

/// Settings and about screen.
struct SettingsView: View {
  private var appVersion: String {
    let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    return "\(version)(\(build))"
  }

  private let privacyPolicyURL = URL(string: "https://timheuer.github.io/gridlet/privacy/")

  var body: some View {
    List {
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
  }
}

#Preview {
  NavigationStack {
    SettingsView()
  }
}
