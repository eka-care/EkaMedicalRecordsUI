// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "EkaMedicalRecordsUI",
  platforms: [
    .iOS(.v17),
    .macOS(.v10_15)
  ],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "EkaMedicalRecordsUI",
      targets: ["EkaMedicalRecordsUI"]),
  ],
  dependencies: [
    .package(url: "https://github.com/SnapKit/SnapKit.git", exact: Version(stringLiteral: "5.0.1")),
    .package(url: "https://github.com/SDWebImage/SDWebImageSwiftUI.git", from: "2.0.0"),
    .package(url: "https://github.com/eka-care/EkaMedicalRecordsCore.git", from: "1.2.2"),
    .package(url: "https://github.com/eka-care/EkaUI.git", from: "1.1.0")
  ],
  targets: [
    .target(
      name: "EkaMedicalRecordsUI",
      dependencies: [
        .product(name: "SnapKit", package: "SnapKit"),
        .product(name: "SDWebImageSwiftUI", package: "SDWebImageSwiftUI"),
        .product(name: "EkaMedicalRecordsCore", package: "EkaMedicalRecordsCore"),
        .product(name: "EkaUI", package: "EkaUI"),
      ],
      resources: [
        .process("Resources")
      ]
    )
  ]
)
