//
//  PrivacyPolicyView.swift
//  WeatherAPP
//
//  Created by Michał Talaga on 16/08/2024.
//

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            Text("""
                **Effective Date:** August 16, 2024

                **1. Introduction**
                Welcome to WeatherApp. We value your privacy and are committed to protecting your personal information. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our application.

                **2. Information We Collect**
                We may collect the following types of information from you:

                • **Personal Information:** Information that you provide directly to us, such as your email address, default city, and preferences.
                • **Usage Data:** Information about your interactions with our app, including device information, IP addresses, and usage statistics.
                • **Location Data:** If you enable location services, we may collect information about your geographic location.

                **3. How We Use Your Information**
                We use your information to:

                • Provide and improve our services
                • Customize your experience
                • Send you updates and notifications
                • Analyze usage trends to enhance our app
                • Respond to your inquiries and support requests

                **4. How We Share Your Information**
                We do not sell or rent your personal information. We may share your information with:

                • **Service Providers:** Third-party vendors who perform services on our behalf, such as analytics or customer support.
                • **Legal Requirements:** If required by law or to protect the rights, property, or safety of our company or others.
                • **Business Transfers:** In the event of a merger, acquisition, or asset sale, your information may be transferred to the acquiring party.

                **5. Security**
                We take reasonable measures to protect your information from unauthorized access, disclosure, or destruction. However, no method of transmission over the internet or electronic storage is 100% secure, and we cannot guarantee absolute security.

                **6. Your Choices**
                You may:

                • **Access and Update Your Information:** You can view and update your personal information within the app.
                • **Opt-Out:** You may opt out of receiving marketing communications by following the instructions provided in those communications.
                • **Delete Your Data:** You can request to delete your account and data by contacting us.

                **7. Changes to This Policy**
                We may update this Privacy Policy from time to time. We will notify you of any significant changes by posting the new policy on this page. Your continued use of the app after such changes constitutes your acceptance of the updated policy.

                **8. Contact Us**
                If you have any questions or concerns about this Privacy Policy or our practices, please contact us at [michal.talaga.programming@gmail.com](mailto:michal.talaga.programming@gmail.com).
                """)
            .padding()
        }
        .navigationTitle("Privacy Policy")
    }
}

#Preview {
    PrivacyPolicyView()
}
