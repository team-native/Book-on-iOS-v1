import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeModule(
    name: "Feature",
    product: .framework,
    organizationName: "Book-on-iOS",
    deploymentTargets: .iOS("16.0"),
    dependencies: [
        .project(target: "Service", path: .relativeToRoot("Projects/Service")),
        .project(target: "ThirdPartyLib", path: .relativeToRoot("Projects/ThirdPartyLib")),
    ],
    sources: ["Sources/**"],
    resources: ["Resources/**"],
    infoPlist: .default
)
