import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeModule(
    name: "Feature",
    product: .framework,
    organizationName: "Book-on-iOS",
    deploymentTargets: .iOS("16.0"),
    dependencies: [
        .project(target: "Service", path: .relativeToRoot("Projects/Service")),
    ],
    sources: ["Sources/**"],
    resources: ["Resources/**"],
    infoPlist: .default
)
