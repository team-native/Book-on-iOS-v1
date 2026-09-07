import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.makeModule(
    name: "Book-on-iOS-V1",
    product: .app,
    organizationName: "Book-on-iOS",
    packages: [
        .remote(
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            requirement: .upToNextMajor(from: "11.0.0")
        ),
    ],
    deploymentTargets: .iOS("16.0"),
    dependencies: [
        .project(target: "Feature", path: .relativeToRoot("Projects/Feature")),
        .project(target: "Service", path: .relativeToRoot("Projects/Service")),
        .project(target: "ThirdPartyLib", path: .relativeToRoot("Projects/ThirdPartyLib")),
        .package(product: "FirebaseCore"),
        .package(product: "FirebaseMessaging"),
    ],
    sources: ["Sources/**"],
    resources: ["Resources/**"],
    entitlements: .file(path: "Book-on-iOS-V1.entitlements"),
    infoPlist: .extendingDefault(
        with: [
            "API_BASE_URL": "http://ssh.gsmsv.site:33839",
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
    ),
    settings: .settings(
        configurations: [
            .debug(name: "Debug", settings: [:]),
            .release(
                name: "Release",
                settings: [
                    "CODE_SIGN_STYLE": "Manual",
                    "CODE_SIGN_IDENTITY": "Apple Distribution",
                    "DEVELOPMENT_TEAM": "DZ9T8FU5CT",
                    "PROVISIONING_PROFILE_SPECIFIER": "BookOn App Store",
                ]
            ),
        ]
    )
)
