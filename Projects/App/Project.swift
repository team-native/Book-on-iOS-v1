import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "Book-on-iOS-V1",
    organizationName: "Book-on-iOS",
    packages: [
        .remote(
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            requirement: .upToNextMajor(from: "11.0.0")
        ),
    ],
    targets: [
        .target(
            name: "Book-on-iOS-V1",
            destinations: .iOS,
            product: .app,
            bundleId: "com.bookonios.Book-on-iOS-V1",
            deploymentTargets: .iOS("16.0"),
            infoPlist: .extendingDefault(
                with: [
                    "API_BASE_URL": "https://bookon.team-native.kr",
                    "CFBundleVersion": "$(CURRENT_PROJECT_VERSION)",
                    "ITSAppUsesNonExemptEncryption": false,
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            entitlements: .file(path: "Book-on-iOS-V1.entitlements"),
            dependencies: [
                .project(target: "Feature", path: .relativeToRoot("Projects/Feature")),
                .project(target: "Service", path: .relativeToRoot("Projects/Service")),
                .package(product: "FirebaseCore"),
                .package(product: "FirebaseMessaging"),
            ],
            settings: .settings(
                configurations: [
                    .debug(name: "Debug", settings: ["CURRENT_PROJECT_VERSION": "1"]),
                    .release(
                        name: "Release",
                        settings: [
                            "CURRENT_PROJECT_VERSION": "1",
                            "CODE_SIGN_STYLE": "Manual",
                            "CODE_SIGN_IDENTITY": "Apple Distribution",
                            "DEVELOPMENT_TEAM": "DZ9T8FU5CT",
                            "PROVISIONING_PROFILE_SPECIFIER": "BookOn App Store Associated Domains",
                        ]
                    ),
                ]
            )
        ),
        .target(
            name: "BookOnUITests",
            destinations: .iOS,
            product: .uiTests,
            bundleId: "com.bookonios.BookOnUITests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["UITests/**"],
            dependencies: [.target(name: "Book-on-iOS-V1")]
        ),
    ],
    schemes: [
        .scheme(
            name: "Book-on-iOS-V1-UI",
            shared: true,
            buildAction: .buildAction(targets: ["Book-on-iOS-V1"]),
            testAction: .targets([.testableTarget(target: "BookOnUITests")])
        ),
    ]
)
