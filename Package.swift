import PackageDescription

let package = Package(
    name: "Rope",
    dependencies: [
        .Package(url: "https://github.com/bermudadigitalstudio/rope-libpq.git", majorVersion: 0, minor: 1)
    ]
)
