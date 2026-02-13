import SwiftUI

struct ProductDetailView: View {
    @EnvironmentObject var viewModel: ShoeStoreViewModel
    @Environment(\.dismiss) var dismiss

    let shoe: Shoe

    @State private var selectedSize: Double?
    @State private var selectedColor: String?
    @State private var showingAddedConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Product Image
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.gray.opacity(0.2))
                        .aspectRatio(1, contentMode: .fit)

                    Image(systemName: "figure.walk")
                        .font(.system(size: 80))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    // Brand
                    Text(shoe.brand)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    // Name
                    Text(shoe.name)
                        .font(.title)
                        .fontWeight(.bold)

                    // Price
                    Text("$\(shoe.price, specifier: "%.2f")")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)

                    // Description
                    Text(shoe.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
                .padding(.horizontal)

                Divider()
                    .padding(.horizontal)

                // Size Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Select Size")
                        .font(.headline)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 8) {
                        ForEach(shoe.sizes, id: \.self) { size in
                            Button {
                                selectedSize = size
                            } label: {
                                Text(String(format: "%.1f", size))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .frame(minWidth: 60, minHeight: 40)
                                    .background(
                                        selectedSize == size ?
                                        Color.blue : Color.gray.opacity(0.2)
                                    )
                                    .foregroundColor(
                                        selectedSize == size ?
                                        .white : .primary
                                    )
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding(.horizontal)

                Divider()
                    .padding(.horizontal)

                // Color Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Select Color")
                        .font(.headline)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 8) {
                        ForEach(shoe.colors, id: \.self) { color in
                            Button {
                                selectedColor = color
                            } label: {
                                Text(color)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .frame(minWidth: 80, minHeight: 40)
                                    .background(
                                        selectedColor == color ?
                                        Color.blue : Color.gray.opacity(0.2)
                                    )
                                    .foregroundColor(
                                        selectedColor == color ?
                                        .white : .primary
                                    )
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding(.horizontal)

                // Add to Cart Button
                Button {
                    addToCart()
                } label: {
                    Text("Add to Cart")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(canAddToCart ? Color.blue : Color.gray)
                        .cornerRadius(12)
                }
                .disabled(!canAddToCart)
                .padding(.horizontal)
                .padding(.top, 8)
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Added to Cart", isPresented: $showingAddedConfirmation) {
            Button("OK", role: .cancel) { }
            Button("View Cart") {
                viewModel.showingCart = true
            }
        } message: {
            Text("\(shoe.name) has been added to your cart.")
        }
    }

    private var canAddToCart: Bool {
        selectedSize != nil && selectedColor != nil
    }

    private func addToCart() {
        guard let size = selectedSize, let color = selectedColor else {
            return
        }

        viewModel.addToCart(shoe: shoe, size: size, color: color)
        showingAddedConfirmation = true
    }
}

#Preview {
    NavigationView {
        ProductDetailView(shoe: Shoe.sampleShoes[0])
            .environmentObject(ShoeStoreViewModel())
    }
}
