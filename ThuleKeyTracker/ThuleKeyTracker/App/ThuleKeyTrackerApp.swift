import SwiftData
import SwiftUI

@main
struct ThuleKeyTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ProductListView()
        }
        .modelContainer(for: ThuleProduct.self)
    }
}
