import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeModule(
    name: "Book-on-iOS-V1",
    product: .app,
    organizationName: "Book-on-iOS",
    deploymentTargets: .iOS("16.0"),
    dependencies: [
        .project(target: "Feature", path: .relativeToRoot("Projects/Feature")),
        .project(target: "Service", path: .relativeToRoot("Projects/Service")),
        .project(target: "ThirdPartyLib", path: .relativeToRoot("Projects/ThirdPartyLib")),
    ],
    sources: ["Sources/**"],
    resources: ["Resources/**"],
    infoPlist: .extendingDefault(
        with: [
            "UILaunchScreen": [
                "UIColorName": "",
                "UIImageName": "",
            ],
            "NSAppTransportSecurity": [
                "NSExceptionDomains": [
                    "ssh.gsmsv.site": [
                        "NSExceptionAllowsInsecureHTTPLoads": true,
                        "NSIncludesSubdomains": true,
                    ],
                ],
            ],
        ]
    )
)
