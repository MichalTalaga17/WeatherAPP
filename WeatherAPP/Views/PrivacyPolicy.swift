import SwiftUI

struct PrivacyPolicyView: View {
    let privacyPolicyText: String = """
    Privacy Policy

    Last updated: August 16, 2024

    Your privacy is important to us. This privacy policy explains how WeatherAPP collects, uses, and discloses your personal information.

    1. Information We Collect
    We may collect the following types of information:
    - Personal identification information (e.g., name, email address)
    - Usage data (e.g., app usage statistics, device information)
    - Location data (if you choose to share your location)

    2. How We Use Your Information
    We use the information we collect for the following purposes:
    - To provide and improve our services
    - To communicate with you, including sending updates and notifications
    - To analyze usage and trends to enhance user experience

    3. How We Share Your Information
    We do not sell or rent your personal information to third parties. We may share your information with:
    - Service providers who assist us in operating our app
    - Law enforcement or other authorities if required by law

    4. Your Choices
    You can control the information you share with us by:
    - Adjusting your app settings
    - Contacting us to request changes or deletions

    5. Security
    We take reasonable measures to protect your information from unauthorized access, but no security system is impenetrable.

    6. Changes to This Policy
    We may update this privacy policy from time to time. We will notify you of any significant changes by updating the policy in the app and on our website.

    7. Contact Us
    If you have any questions or concerns about this privacy policy, please contact us at michal.talaga.programming@gmail.com.

    Thank you for using WeatherAPP!

    """

    var body: some View {
        ScrollView {
            Text(privacyPolicyText)
                .padding()
                .font(.body)
                .foregroundColor(.primary)
        }
        .navigationTitle("Privacy Policy")
    }
}

#Preview {
    PrivacyPolicyView()
}
