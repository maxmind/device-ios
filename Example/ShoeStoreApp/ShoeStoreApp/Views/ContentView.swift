import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: ShoeStoreViewModel

    var body: some View {
        NavigationView {
            ProductListView()
                .navigationTitle("Shoe Store")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            viewModel.showingCart = true
                        } label: {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "cart")
                                    .font(.title3)

                                if !viewModel.cartIsEmpty {
                                    Text("\(viewModel.cartItemCount)")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .frame(width: 16, height: 16)
                                        .background(Color.red)
                                        .clipShape(Circle())
                                        .offset(x: 8, y: -8)
                                }
                            }
                        }
                    }
                }
                .sheet(isPresented: $viewModel.showingCart) {
                    CartView()
                }
                .sheet(isPresented: $viewModel.showingCheckout) {
                    CheckoutView()
                }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ShoeStoreViewModel())
}
