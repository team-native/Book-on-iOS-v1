import ProjectDescription

let project = Project(
    name: "Book-on-iOS-V1",
    targets: [

        // MARK: - App
        .target(
            name: "Book-on-iOS-V1",
            destinations: .iOS,
            product: .app,
            bundleId: "dev.tuist.Book-on-iOS-V1",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["Book-on-iOS-V1/Sources/**"],
            resources: ["Book-on-iOS-V1/Resources/**"],
            dependencies: [
                .target(name: "FeatureBookList"),
                .target(name: "FeatureBookDetail"),
                .target(name: "FeatureSearch"),
            ]
        ),

        // MARK: - Shared
        .target(
            name: "Shared",
            destinations: .iOS,
            product: .framework,
            bundleId: "dev.tuist.Shared",
            sources: ["Shared/Sources/**"],
            dependencies: []
        ),

        // MARK: - Domain
        .target(
            name: "Domain",
            destinations: .iOS,
            product: .framework,
            bundleId: "dev.tuist.Domain",
            sources: ["Domain/Sources/**"],
            dependencies: [.target(name: "Shared")]
        ),

        // MARK: - Data
        .target(
            name: "Data",
            destinations: .iOS,
            product: .framework,
            bundleId: "dev.tuist.Data",
            sources: ["Data/Sources/**"],
            dependencies: [.target(name: "Domain")]
        ),

        // MARK: - Feature: BookList
        .target(
            name: "FeatureBookList",
            destinations: .iOS,
            product: .framework,
            bundleId: "dev.tuist.FeatureBookList",
            sources: ["Feature/BookList/Sources/**"],
            dependencies: [
                .target(name: "Domain"),
                .target(name: "Shared"),
            ]
        ),

        // MARK: - Feature: BookDetail
        .target(
            name: "FeatureBookDetail",
            destinations: .iOS,
            product: .framework,
            bundleId: "dev.tuist.FeatureBookDetail",
            sources: ["Feature/BookDetail/Sources/**"],
            dependencies: [
                .target(name: "Domain"),
                .target(name: "Shared"),
            ]
        ),

        // MARK: - Feature: Search
        .target(
            name: "FeatureSearch",
            destinations: .iOS,
            product: .framework,
            bundleId: "dev.tuist.FeatureSearch",
            sources: ["Feature/Search/Sources/**"],
            dependencies: [
                .target(name: "Domain"),
                .target(name: "Shared"),
            ]
        ),

        // MARK: - Tests
        .target(
            name: "Book-on-iOS-V1Tests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "dev.tuist.Book-on-iOS-V1Tests",
            sources: ["Book-on-iOS-V1/Tests/**"],
            dependencies: [.target(name: "Book-on-iOS-V1")]
        ),
    ]
)
