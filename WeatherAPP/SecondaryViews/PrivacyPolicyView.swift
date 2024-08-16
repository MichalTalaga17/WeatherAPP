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
            VStack(alignment: .leading, spacing: 16) {
                
                Text("Effective Date: August 16, 2024")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text("1. Introduction")
                    .font(.headline)
                    .padding(.top, 16)
                Text("Welcome to WeatherApp. We value your privacy and are committed to protecting your personal information. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our application.")
                
                Text("2. Information We Collect")
                    .font(.headline)
                    .padding(.top, 16)
                Text("We may collect the following types of information from you:\n\n• **Personal Information:** Information that you provide directly to us, such as your email address, default city, and preferences.\n• **Usage Data:** Information about your interactions with our app, including device information, IP addresses, and usage statistics.\n• **Location Data:** If you enable location services, we may collect information about your geographic location.")
                
                Text("3. How We Use Your Information")
                    .font(.headline)
                    .padding(.top, 16)
                Text("We use your information to:\n\n• Provide and improve our services\n• Customize your experience\n• Send you updates and notifications\n• Analyze usage trends to enhance our app\n• Respond to your inquiries and support requests")
                
                Text("4. How We Share Your Information")
                    .font(.headline)
                    .padding(.top, 16)
                Text("We do not sell or rent your personal information. We may share your information with:\n\n• **Service Providers:** Third-party vendors who perform services on our behalf, such as analytics or customer support.\n• **Legal Requirements:** If required by law or to protect the rights, property, or safety of our company or others.\n• **Business Transfers:** In the event of a merger, acquisition, or asset sale, your information may be transferred to the acquiring party.")
                
                Text("5. Security")
                    .font(.headline)
                    .padding(.top, 16)
                Text("We take reasonable measures to protect your information from unauthorized access, disclosure, or destruction. However, no method of transmission over the internet or electronic storage is 100% secure, and we cannot guarantee absolute security.")
                
                Text("6. Your Choices")
                    .font(.headline)
                    .padding(.top, 16)
                Text("You may:\n\n• **Access and Update Your Information:** You can view and update your personal information within the app.\n• **Opt-Out:** You may opt out of receiving marketing communications by following the instructions provided in those communications.\n• **Delete Your Data:** You can request to delete your account and data by contacting us.")
                
                Text("7. Changes to This Policy")
                    .font(.headline)
                    .padding(.top, 16)
                Text("We may update this Privacy Policy from time to time. We will notify you of any significant changes by posting the new policy on this page. Your continued use of the app after such changes constitutes your acceptance of the updated policy.")
                
                Text("8. Contact Us")
                    .font(.headline)
                    .padding(.top, 16)
                Section(header: Text("Links")) {
                    Text("If you have any questions or concerns about this Privacy Policy or our practices, please contact us")
                    Link("Contact Support", destination: URL(string: "mailto:michal.talaga.programming@gmail.com")!)
                }
                
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
    }
}

#Preview {
    PrivacyPolicyView()
}
