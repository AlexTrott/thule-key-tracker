import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text(String(localized: "Last updated: April 2026"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                policySection(
                    title: String(localized: "Overview"),
                    body: String(localized: "Thule Key Tracker is designed with your privacy in mind. The app operates entirely offline and does not collect, transmit, or share any personal data.")
                )

                policySection(
                    title: String(localized: "Data Storage"),
                    body: String(localized: "All data you enter — including product types, key codes, nicknames, and notes — is stored locally on your device using Apple's SwiftData framework. If you have iCloud enabled, your data may sync across your devices via your personal iCloud account. This sync is handled entirely by Apple and is subject to Apple's Privacy Policy.")
                )

                policySection(
                    title: String(localized: "Data Collection"),
                    body: String(localized: "This app does not collect any data. There are no analytics, no tracking, no crash reporting, and no third-party SDKs. We have no servers and no way to access your data.")
                )

                policySection(
                    title: String(localized: "Third-Party Services"),
                    body: String(localized: "This app does not use any third-party services, advertising frameworks, or analytics tools. The app contains no network calls of any kind.")
                )

                policySection(
                    title: String(localized: "Data Export"),
                    body: String(localized: "You can export your data as a JSON file using the backup feature in Settings. This file is saved to a location you choose and is not sent anywhere by the app.")
                )

                policySection(
                    title: String(localized: "Your Rights"),
                    body: String(localized: "Since all data is stored locally on your device, you have full control over it at all times. You can delete individual products or all data from within the app. Uninstalling the app will remove all locally stored data.")
                )

                policySection(
                    title: String(localized: "Changes to This Policy"),
                    body: String(localized: "Any updates to this privacy policy will be included in future app updates. The date at the top of this page indicates when the policy was last revised.")
                )

                policySection(
                    title: String(localized: "Contact"),
                    body: String(localized: "If you have questions about this privacy policy, you can reach us through the App Store support link on the app's listing page.")
                )
            }
            .padding(.horizontal, ThuleTheme.horizontalPadding)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .background(ThuleTheme.background)
        .navigationTitle(String(localized: "Privacy Policy"))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func policySection(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(body)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        PrivacyPolicyView()
    }
    .preferredColorScheme(.dark)
}
