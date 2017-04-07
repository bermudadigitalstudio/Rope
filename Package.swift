import PackageDescription

var package = Package(
    name: "Rope",
    dependencies: [
        .Package(url: "https://github.com/bermudadigitalstudio/rope-libpq.git", majorVersion: 0, minor: 2),
    ]
)

// package.dependencies.append(.Package(url: "https://github.com/krzysztofzablocki/Sourcery.git", majorVersion: 0))
