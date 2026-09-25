import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeModule(
    name: "Service",
    product: .framework,
    organizationName: "Book-on-iOS",
    deploymentTargets: .iOS("16.0"),
    dependencies: [],
    sources: ["Sources/**"],
    infoPlist: .default
)
