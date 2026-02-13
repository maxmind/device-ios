import SwiftUI

struct CartView: View {
    @EnvironmentObject var viewModel: ShoeStoreViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Group {
                if viewModel.cartIsEmpty {
                    emptyCartView
                } else {
                    cartContentView
                }
            }
            .navigationTitle("Shopping Cart")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var emptyCartView: some View {
        VStack(spacing: 20) {
            Image(systemName: "cart")
                .font(.system(size: 80))
                .foregroundColor(.gray)

            Text("Your cart is empty")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Add some shoes to get started")
                .font(.body)
                .foregroundColor(.secondary)
        }
    }

    private var cartContentView: some View {
        VStack(spacing: 0) {
            // Cart Items List
            List {
                ForEach(viewModel.cartItems) { item in
                    CartItemRow(item: item)
                }
                .onDelete { indexSet in
                    indexSet.forEach { index in
                        viewModel.removeFromCart(item: viewModel.cartItems[index])
                    }
                }
            }
            .listStyle(.plain)

            // Cart Summary
            VStack(spacing: 16) {
                Divider()

                HStack {
                    Text("Subtotal")
                        .font(.body)
                    Spacer()
                    Text("$\(viewModel.cartTotal, specifier: "%.2f")")
                        .font(.body)
                        .fontWeight(.medium)
                }

                HStack {
                    Text("Total Items")
                        .font(.body)
                    Spacer()
                    Text("\(viewModel.cartItemCount)")
                        .font(.body)
                        .fontWeight(.medium)
                }

                Button {
                    viewModel.proceedToCheckout()
                } label: {
                    Text("Proceed to Checkout")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
        }
    }
}

struct CartItemRow: View {
    @EnvironmentObject var viewModel: ShoeStoreViewModel
    let item: CartItem

    var body: some View {
        HStack(spacing: 12) {
            // Image
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 80, height: 80)

                Image(systemName: "figure.walk")
                    .font(.title)
                    .foregroundColor(.gray)
            }

            // Details
            VStack(alignment: .leading, spacing: 4) {
                Text(item.shoe.name)
                    .font(.headline)
                    .lineLimit(2)

                Text(item.shoe.brand)
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack(spacing: 8) {
                    Text("Size: \(String(format: "%.1f", item.size))")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("•")
                        .foregroundColor(.secondary)

                    Text(item.color)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("$\(item.shoe.price, specifier: "%.2f")")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)

                    Spacer()

                    // Quantity Stepper
                    HStack(spacing: 12) {
                        Button {
                            viewModel.updateQuantity(for: item, quantity: item.quantity - 1)
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.blue)
                        }

                        Text("\(item.quantity)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .frame(minWidth: 20)

                        Button {
                            viewModel.updateQuantity(for: item, quantity: item.quantity + 1)
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    let viewModel = ShoeStoreViewModel()
    viewModel.addToCart(shoe: Shoe.sampleShoes[0], size: 9.5, color: "Black")
    viewModel.addToCart(shoe: Shoe.sampleShoes[1], size: 10.0, color: "White")

    return CartView()
        .environmentObject(viewModel)
}
