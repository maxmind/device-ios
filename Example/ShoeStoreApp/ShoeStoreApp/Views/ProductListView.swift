import SwiftUI

struct ProductListView: View {
    @EnvironmentObject var viewModel: ShoeStoreViewModel

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.shoes) { shoe in
                    NavigationLink(destination: ProductDetailView(shoe: shoe)) {
                        ProductCard(shoe: shoe)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
    }
}

struct ProductCard: View {
    let shoe: Shoe

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Placeholder image
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .aspectRatio(1, contentMode: .fit)

                Image(systemName: "figure.walk")
                    .font(.system(size: 40))
                    .foregroundColor(.gray)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(shoe.brand)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(shoe.name)
                    .font(.headline)
                    .lineLimit(2)
                    .foregroundColor(.primary)

                Text("$\(shoe.price, specifier: "%.2f")")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
        }
        .padding(8)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    NavigationView {
        ProductListView()
            .environmentObject(ShoeStoreViewModel())
    }
}
