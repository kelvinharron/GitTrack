import ProjectDescription

let project = Project(
    name: "GitTrack",
    targets: [
        .target(
            name: "GitTrack",
            destinations: .macOS,
            product: .app,
            bundleId: "com.kelvinharron.gittrack",
            infoPlist: .extendingDefault(with:
                ["LSUIElement": "YES"]
            ),
            sources: ["App/Sources/**"],
            resources: ["App/Resources/**"],
            dependencies: [
                .external(name: "MarkdownUI"),
            ]
        ),
        .target(
            name: "GitTrackTests",
            destinations: .macOS,
            product: .unitTests,
            bundleId: "io.tuist.GitTrackTests",
            infoPlist: .default,
            sources: ["App/Tests/**"],
            resources: [],
            dependencies: [.target(name: "GitTrack")]
        ),
    ]
)
