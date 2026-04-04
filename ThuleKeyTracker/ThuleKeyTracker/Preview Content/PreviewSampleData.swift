import SwiftData

@MainActor
enum PreviewSampleData {

    static var sampleProducts: [ThuleProduct] {
        [
            ThuleProduct(
                productType: .roofBox,
                keyCode: "N125",
                nickname: "Motion XT XL",
                notes: "Spare key in kitchen drawer",
                numberOfLocks: 2
            ),
            ThuleProduct(
                productType: .bikeRackTowbar,
                keyCode: "N125",
                nickname: "EasyFold XT 2",
                numberOfLocks: 1
            ),
            ThuleProduct(
                productType: .roofBars,
                keyCode: "N042",
                nickname: "WingBar Evo",
                numberOfLocks: 4
            ),
            ThuleProduct(
                productType: .skiCarrier,
                keyCode: "N042",
                numberOfLocks: 1
            ),
            ThuleProduct(
                productType: .kayakCarrier,
                keyCode: "N200",
                nickname: "Hull-a-Port XT",
                numberOfLocks: 2
            ),
        ]
    }

    static var container: ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: ThuleProduct.self,
            configurations: config
        )
        for product in sampleProducts {
            container.mainContext.insert(product)
        }
        return container
    }
}
