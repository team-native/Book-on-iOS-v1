import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeModule(
    name: "ThirdPartyLib",
    product: .framework,
    organizationName: "Book-on-iOS",
    deploymentTargets: .iOS("16.0"),
    dependencies: [
        // SPM 패키지 추가 예시:
        // .package(product: "Moya"),
        // .package(product: "Kingfisher"),
    ],
    sources: ["Sources/**"],
    infoPlist: .default
)
