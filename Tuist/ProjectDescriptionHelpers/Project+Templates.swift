import ProjectDescription

public extension Project {
    static func makeModule(
        name: String,
        product: Product,
        organizationName: String = "Book-on-iOS",
        packages: [Package] = [],
        deploymentTargets: DeploymentTargets? = .iOS("16.0"),
        dependencies: [TargetDependency] = [],
        sources: SourceFilesList = ["Sources/**"],
        resources: ResourceFileElements? = nil,
        entitlements: Entitlements? = nil,
        infoPlist: InfoPlist = .default
    ) -> Project {

        let targets: [Target] = [
            .target(
                name: name,
                destinations: .iOS,
                product: product,
                bundleId: "com.bookonios.\(name)",
                deploymentTargets: deploymentTargets,
                infoPlist: infoPlist,
                sources: sources,
                resources: resources,
                entitlements: entitlements,
                dependencies: dependencies
            )
        ]

        return Project(
            name: name,
            organizationName: organizationName,
            packages: packages,
            targets: targets
        )
    }
}
