//
//  LicenseActivationView.swift
//  Clipso
//
//  License activation view for manual key entry
//

import SwiftUI

// MARK: - License Activation View
struct LicenseActivationView: View {
    @StateObject private var licenseManager = LemonSqueezyManager.shared
    @State private var licenseKey = ""
    @State private var email = ""
    @State private var isActivating = false
    @State private var errorMessage: String?
    @State private var showSuccess = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("Activate Pro License")
                .font(.title)
                .fontWeight(.bold)

            Text("Enter your license key from your Lemon Squeezy purchase email")
                .font(.subheadline)
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 10) {
                Text("Email")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("your@email.com", text: $email)
                    .textFieldStyle(.roundedBorder)

                Text("License Key")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("XXXX-XXXX-XXXX-XXXX", text: $licenseKey)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(.body, design: .monospaced))
            }

            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Button(action: activateLicense) {
                if isActivating {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .scaleEffect(0.7)
                } else {
                    Text("Activate License")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(licenseKey.isEmpty || email.isEmpty || isActivating)

            Divider()

            VStack(spacing: 12) {
                Text("Or purchase a license:")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Button("Purchase Lifetime ($29.99)") {
                    licenseManager.purchaseLifetime()
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)

                Button("Purchase Annual ($7.99/year)") {
                    licenseManager.purchaseAnnual()
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
            }

            Spacer()
        }
        .padding(30)
        .frame(width: 500)
        .alert("License Activated!", isPresented: $showSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your Pro features have been activated!")
        }
    }

    private func activateLicense() {
        isActivating = true
        errorMessage = nil

        Task {
            do {
                try await licenseManager.activateLicense(key: licenseKey, email: email)
                await MainActor.run {
                    isActivating = false
                    showSuccess = true
                }
            } catch {
                await MainActor.run {
                    isActivating = false
                    errorMessage = "Invalid license key or email. Please check and try again."
                }
            }
        }
    }
}

#Preview {
    LicenseActivationView()
}
