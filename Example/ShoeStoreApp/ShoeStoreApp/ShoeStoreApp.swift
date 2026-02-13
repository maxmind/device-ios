import SwiftUI

@main
struct ShoeStoreApp: App {
    @StateObject private var viewModel = ShoeStoreViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
