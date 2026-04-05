import SwiftData
import SwiftUI

@main
struct ThuleKeyTrackerApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            let config = ModelConfiguration(
                "ThuleKeyTracker",
                cloudKitDatabase: .automatic
            )
            modelContainer = try ModelContainer(
                for: ThuleProduct.self,
                configurations: config
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ProductListView()
        }
        .modelContainer(modelContainer)
    }
}
