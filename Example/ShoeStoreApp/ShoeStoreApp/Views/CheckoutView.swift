import SwiftUI

struct CheckoutView: View {
    @EnvironmentObject var viewModel: ShoeStoreViewModel
    @Environment(\.dismiss) var dismiss

    @State private var showingSuccess = false
    @State private var isProcessing = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Order Summary
                    orderSummarySection

                    // Fraud Detection Info
                    fraudDetectionSection

                    // Payment Info (Mock)
                    paymentSection

                    // Place Order Button
                    placeOrderButton
                }
                .padding()
            }
            .navigationTitle("Checkout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Order Placed!", isPresented: $showingSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your order has been successfully placed. Thank you for shopping with us!")
            }
            .task {
                // Analyze fraud when checkout view appears
                if !viewModel.fraudAnalysisComplete {
                    await viewModel.analyzeCartForFraud()
                }
            }
        }
    }

    private var orderSummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Order Summary")
                .font(.headline)

            Divider()

            ForEach(viewModel.cartItems) { item in
                HStack {
                    Text("\(item.quantity)x \(item.shoe.name)")
                        .font(.body)
                    Spacer()
                    Text("$\(item.totalPrice, specifier: "%.2f")")
                        .font(.body)
                        .fontWeight(.medium)
                }
            }

            Divider()

            HStack {
                Text("Total")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
                Text("$\(viewModel.cartTotal, specifier: "%.2f")")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }

    private var fraudDetectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "shield.checkered")
                    .foregroundColor(.blue)
                Text("Fraud Detection")
                    .font(.headline)
            }

            Divider()

            // Device ID
            if let deviceId = viewModel.fraudService.deviceId {
                HStack(alignment: .top) {
                    Text("Device ID:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(deviceId)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.trailing)
                }
            }

            // DeviceCheck Support
            HStack {
                Text("DeviceCheck:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(viewModel.fraudService.isDeviceCheckSupported ? "Supported" : "Not Available")
                    .font(.subheadline)
                    .foregroundColor(viewModel.fraudService.isDeviceCheckSupported ? .green : .orange)
            }

            // Fraud Risk Level
            if viewModel.isAnalyzingFraud {
                HStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                    Text("Analyzing transaction...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            } else if viewModel.fraudAnalysisComplete {
                HStack {
                    Text("Risk Level:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    HStack(spacing: 6) {
                        Circle()
                            .fill(riskLevelColor)
                            .frame(width: 8, height: 8)
                        Text(viewModel.fraudService.fraudRiskLevel.rawValue)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(riskLevelColor)
                    }
                }
            }

            // Info Message
            Text("This transaction is protected by MaxMind minFraud Device SDK")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 4)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }

    private var riskLevelColor: Color {
        switch viewModel.fraudService.fraudRiskLevel {
        case .unknown:
            return .gray
        case .low:
            return .green
        case .medium:
            return .orange
        case .high:
            return .red
        }
    }

    private var paymentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Payment Method")
                .font(.headline)

            Divider()

            // Mock payment info
            HStack {
                Image(systemName: "creditcard.fill")
                    .foregroundColor(.blue)
                VStack(alignment: .leading) {
                    Text("Visa ending in 4242")
                        .font(.subheadline)
                    Text("Expires 12/25")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button("Change") {
                    // Mock button
                }
                .font(.subheadline)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }

    private var placeOrderButton: some View {
        Button {
            placeOrder()
        } label: {
            if isProcessing {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
            } else {
                Text("Place Order")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
            }
        }
        .background(canPlaceOrder ? Color.blue : Color.gray)
        .cornerRadius(12)
        .disabled(!canPlaceOrder || isProcessing)
    }

    private var canPlaceOrder: Bool {
        !viewModel.cartIsEmpty &&
        viewModel.fraudAnalysisComplete &&
        !viewModel.isAnalyzingFraud
    }

    private func placeOrder() {
        isProcessing = true

        Task {
            do {
                try await viewModel.completePurchase()
                showingSuccess = true
            } catch {
                // Handle error
                print("Purchase failed: \(error)")
            }
            isProcessing = false
        }
    }
}

#Preview {
    let viewModel = ShoeStoreViewModel()
    viewModel.addToCart(shoe: Shoe.sampleShoes[0], size: 9.5, color: "Black")
    viewModel.addToCart(shoe: Shoe.sampleShoes[2], size: 10.5, color: "Brown")

    return CheckoutView()
        .environmentObject(viewModel)
}
