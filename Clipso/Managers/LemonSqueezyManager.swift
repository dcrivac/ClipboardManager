//
//  LemonSqueezyManager.swift
//  Clipso
//
//  License and subscription management via Lemon Squeezy
//

import Foundation
import Combine

// MARK: - Lemon Squeezy Manager
class LemonSqueezyManager: NSObject, ObservableObject {
    static let shared = LemonSqueezyManager()

    @Published var isProUser: Bool = false
    @Published var licenseType: LicenseType = .free
    @Published var licenseEmail: String?
    @Published var licenseKey: String?

    // Lemon Squeezy Configuration
    private let storeId = "YOUR_LEMON_SQUEEZY_STORE_ID" // Replace with actual Store ID
    private let lifetimeProductId = "YOUR_LIFETIME_PRODUCT_ID" // Replace with actual Product ID
    private let annualProductId = "YOUR_ANNUAL_PRODUCT_ID" // Replace with actual Product ID

    // Keychain keys
    private let licenseKeyKeychainKey = "com.clipso.license.key"
    private let licenseEmailKeychainKey = "com.clipso.license.email"
    private let licenseTypeKeychainKey = "com.clipso.license.type"

    enum LicenseType: String, Codable {
        case free = "free"
        case lifetime = "lifetime"
        case annual = "annual"
    }

    enum LicenseError: Error {
        case invalidKey
        case validationFailed
        case networkError
        case alreadyActivated
    }

    private override init() {
        super.init()
        loadLicenseFromKeychain()
    }

    // MARK: - Public Methods

    /// Check if user has Pro features
    func hasProAccess() -> Bool {
        return isProUser && (licenseType == .lifetime || licenseType == .annual)
    }

    /// Activate license with key and email
    func activateLicense(key: String, email: String) async throws {
        guard !key.isEmpty, !email.isEmpty else {
            throw LicenseError.invalidKey
        }

        // Validate with Lemon Squeezy API
        let isValid = try await validateLicenseWithLemonSqueezy(key: key, email: email)

        guard isValid else {
            throw LicenseError.validationFailed
        }

        // Determine license type from validation response
        let type = try await determineLicenseType(key: key, email: email)

        // Save to Keychain
        try saveLicenseToKeychain(key: key, email: email, type: type)

        // Update state
        await MainActor.run {
            self.isProUser = true
            self.licenseType = type
            self.licenseEmail = email
            self.licenseKey = key
        }
    }

    /// Deactivate license (for logout or refund)
    func deactivateLicense() {
        deleteLicenseFromKeychain()
        isProUser = false
        licenseType = .free
        licenseEmail = nil
        licenseKey = nil
    }

    /// Open Lemon Squeezy checkout for lifetime purchase
    func purchaseLifetime() {
        let checkoutURL = "https://\(storeId).lemonsqueezy.com/checkout/buy/\(lifetimeProductId)"
        if let url = URL(string: checkoutURL) {
            NSWorkspace.shared.open(url)
        }
    }

    /// Open Lemon Squeezy checkout for annual subscription
    func purchaseAnnual() {
        let checkoutURL = "https://\(storeId).lemonsqueezy.com/checkout/buy/\(annualProductId)"
        if let url = URL(string: checkoutURL) {
            NSWorkspace.shared.open(url)
        }
    }

    /// Open license activation view (for manual key entry)
    func showLicenseActivation() {
        // This will trigger the license activation sheet in the UI
    }

    // MARK: - Feature Gating

    func canUseSemanticSearch() -> Bool {
        return hasProAccess()
    }

    func canUseContextDetection() -> Bool {
        return hasProAccess()
    }

    func getMaxItems() -> Int {
        return hasProAccess() ? Int.max : 250
    }

    func getMaxRetentionDays() -> Int {
        return hasProAccess() ? Int.max : 30
    }

    // MARK: - Private Methods

    private func validateLicenseWithLemonSqueezy(key: String, email: String) async throws -> Bool {
        // Lemon Squeezy License Verification API
        // https://docs.lemonsqueezy.com/api/licenses/validate-license

        let urlString = "https://api.lemonsqueezy.com/v1/licenses/validate"
        guard let url = URL(string: urlString) else {
            throw LicenseError.networkError
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "license_key": key,
            "instance_name": email
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw LicenseError.networkError
        }

        // Parse response
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let valid = json["valid"] as? Bool {
            return valid
        }

        return false
    }

    private func determineLicenseType(key: String, email: String) async throws -> LicenseType {
        // Query Lemon Squeezy API to determine license type
        // For now, default to lifetime
        // In production, you'd parse the license metadata to determine type
        return .lifetime
    }

    // MARK: - Keychain Management

    private func loadLicenseFromKeychain() {
        guard let key = getFromKeychain(key: licenseKeyKeychainKey),
              let email = getFromKeychain(key: licenseEmailKeychainKey),
              let typeString = getFromKeychain(key: licenseTypeKeychainKey),
              let type = LicenseType(rawValue: typeString) else {
            return
        }

        self.isProUser = true
        self.licenseType = type
        self.licenseEmail = email
        self.licenseKey = key
    }

    private func saveLicenseToKeychain(key: String, email: String, type: LicenseType) throws {
        saveToKeychain(key: licenseKeyKeychainKey, value: key)
        saveToKeychain(key: licenseEmailKeychainKey, value: email)
        saveToKeychain(key: licenseTypeKeychainKey, value: type.rawValue)
    }

    private func deleteLicenseFromKeychain() {
        deleteFromKeychain(key: licenseKeyKeychainKey)
        deleteFromKeychain(key: licenseEmailKeychainKey)
        deleteFromKeychain(key: licenseTypeKeychainKey)
    }

    // Generic Keychain helpers
    private func saveToKeychain(key: String, value: String) {
        let data = value.data(using: .utf8)!

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        // Delete existing
        SecItemDelete(query as CFDictionary)

        // Add new
        SecItemAdd(query as CFDictionary, nil)
    }

    private func getFromKeychain(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }

        return string
    }

    private func deleteFromKeychain(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - License Status Display
extension LemonSqueezyManager {
    func getLicenseStatusText() -> String {
        switch licenseType {
        case .free:
            return "Free Plan"
        case .lifetime:
            return "Lifetime Pro"
        case .annual:
            return "Annual Pro"
        }
    }
}
