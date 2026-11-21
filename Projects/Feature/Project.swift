import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "Feature",
    organizationName: "Book-on-iOS",
    targets: [
        .target(
            name: "Feature",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.bookonios.Feature",
            deploymentTargets: .iOS("16.0"),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: [
                .project(target: "Service", path: .relativeToRoot("Projects/Service")),
            ]
        ),
        .target(
            name: "FeatureTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.bookonios.FeatureTests",
            deploymentTargets: .iOS("17.0"),
            sources: ["Tests/**"],
            dependencies: [.target(name: "Feature")]
        ),
    ],
    schemes: [
        .scheme(
            name: "Feature",
            shared: true,
            testAction: .targets([.testableTarget(target: "FeatureTests")])
        ),
    ]
)
