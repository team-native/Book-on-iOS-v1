import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "Service",
    organizationName: "Book-on-iOS",
    targets: [
        .target(
            name: "Service",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.bookonios.Service",
            deploymentTargets: .iOS("16.0"),
            infoPlist: .default,
            sources: ["Sources/**"]
        ),
        .target(
            name: "ServiceTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.bookonios.ServiceTests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: [.target(name: "Service")]
        ),
    ],
    schemes: [
        .scheme(
            name: "Service",
            shared: true,
            buildAction: .buildAction(targets: ["Service"]),
            testAction: .targets(["ServiceTests"])
        ),
    ]
)
