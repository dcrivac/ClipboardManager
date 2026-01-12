//
//  RevenueCatPaywallView.swift
//  Clipso
//
//  In-app purchase paywall using RevenueCat
//

import SwiftUI
import StoreKit

// MARK: - RevenueCat Paywall View
struct RevenueCatPaywallView: View {
    @StateObject private var licenseManager = RevenueCatManager.shared
    @Environment(\.dismiss) var dismiss
    @State private var selectedProduct: StoreProduct?
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Upgrade to Pro")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.system(size: 16))
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Features comparison
                    VStack(spacing: 16) {
                        Text("Features")
                            .font(.headline)
                            .fontWeight(.semibold)

                        VStack(alignment: .leading, spacing: 10) {
                            FeatureRow(icon: "brain.head.profile", text: "AI Semantic Search", pro: true)
                            FeatureRow(icon: "chart.pie", text: "Context Detection", pro: true)
                            FeatureRow(icon: "infinity", text: "Unlimited Items", pro: true)
                            FeatureRow(icon: "clock", text: "Unlimited Retention", pro: true)
                            FeatureRow(icon: "key.fill", text: "Keyword Search", pro: false)
                        }
                    }
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)

                    // Pricing options
                    VStack(spacing: 12) {
                        Text("Choose Your Plan")
                            .font(.headline)
                            .fontWeight(.semibold)

                        if licenseManager.availableProducts.isEmpty {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            ForEach(licenseManager.availableProducts, id: \.productIdentifier) { product in
                                PricingOptionView(
                                    product: product,
                                    isSelected: selectedProduct?.productIdentifier == product.productIdentifier,
                                    onSelect: { selectedProduct = product }
                                )
                            }
                        }
                    }

                    // Purchase button
                    if let selected = selectedProduct {
                        Button(action: purchaseProduct) {
                            if licenseManager.isLoading {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .scaleEffect(0.8)
                            } else {
                                Text("Purchase \(selected.priceFormattedString)")
                                    .fontWeight(.semibold)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity)
                        .disabled(licenseManager.isLoading)
                    }

                    // Error message
                    if let error = errorMessage {
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                Text(error)
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(6)
                    }

                    // Restore purchases
                    Button(action: restorePurchases) {
                        Text("Restore Previous Purchases")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity)

                    // Footer note
                    VStack(spacing: 4) {
                        Text("Subscriptions auto-renew unless canceled")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("Lifetime purchases never expire")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
                }
                .padding()
            }
        }
        .frame(minWidth: 450, minHeight: 500)
        .onAppear {
            Task {
                await licenseManager.fetchAvailableProducts()
            }
        }
    }

    private func purchaseProduct() {
        guard let product = selectedProduct else { return }

        Task {
            isLoading = true
            errorMessage = nil

            do {
                try await licenseManager.purchase(productID: product.productIdentifier)
                // Purchase successful
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    dismiss()
                }
            } catch {
                errorMessage = "Purchase failed. Please try again."
            }

            isLoading = false
        }
    }

    private func restorePurchases() {
        Task {
            isLoading = true
            errorMessage = nil

            do {
                try await licenseManager.restorePurchases()
                errorMessage = "Purchases restored successfully!"
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    dismiss()
                }
            } catch {
                errorMessage = "Failed to restore purchases. Please check your internet and try again."
            }

            isLoading = false
        }
    }
}

// MARK: - Pricing Option View
struct PricingOptionView: View {
    let product: StoreProduct
    let isSelected: Bool
    let onSelect: () -> Void

    var displayName: String {
        // Map product IDs to display names
        switch product.productIdentifier {
        case "com.clipso.lifetime":
            return "Lifetime Access"
        case "com.clipso.annual":
            return "Annual Subscription"
        default:
            return product.localizedTitle
        }
    }

    var description: String {
        switch product.productIdentifier {
        case "com.clipso.lifetime":
            return "One-time payment, forever access"
        case "com.clipso.annual":
            return "Renews every year"
        default:
            return product.description
        }
    }

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(displayName)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text(product.priceFormattedString)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color(NSColor.controlBackgroundColor))
            .border(isSelected ? Color.blue : Color.clear, width: 2)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let icon: String
    let text: String
    let pro: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 20)
                .foregroundColor(pro ? .blue : .secondary)
            Text(text)
                .foregroundColor(pro ? .primary : .secondary)
            Spacer()
            if pro {
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
    }
}

#Preview {
    RevenueCatPaywallView()
}
