import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeModule(
    name: "Service",
    product: .framework,
    organizationName: "Book-on-iOS",
    deploymentTargets: .iOS("16.0"),
    dependencies: [
        .project(target: "ThirdPartyLib", path: .relativeToRoot("Projects/ThirdPartyLib")),
    ],
    sources: ["Sources/**"],
    infoPlist: .default
)
