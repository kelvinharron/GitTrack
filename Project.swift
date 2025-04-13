import ProjectDescription

let project = Project(
    name: "GitTrack",
    targets: [
        .target(
            name: "GitTrack",
            destinations: .macOS,
            product: .app,
            bundleId: "io.tuist.GitTrack",
            infoPlist: .default,
            sources: ["App/Sources/**"],
            resources: ["App/Resources/**"],
            dependencies: []
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
