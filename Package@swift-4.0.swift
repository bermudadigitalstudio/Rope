// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Rope",
    products: [
        .library(name: "Rope", targets: ["Rope"])
    ],
    dependencies: [
        .package(url: "https://github.com/bermudadigitalstudio/RopeLibpq.git", .upToNextMinor(from: "0.3.0")),        
    ],
    targets:[
        .target(name:"Rope", dependencies: ["RopeLibpq"]),
        .testTarget(name: "RopeTests", dependencies: ["Rope"])
    ]
)