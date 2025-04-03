// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "EkaMedicalRecordsUI",
  platforms: [
    .iOS(.v17)
  ],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "EkaMedicalRecordsUI",
      targets: ["EkaMedicalRecordsUI"]),
  ],
  dependencies: [
    .package(url: "https://github.com/SnapKit/SnapKit.git", exact: Version(stringLiteral: "5.0.1")),
    .package(url: "https://github.com/SDWebImage/SDWebImageSwiftUI.git", from: "3.1.3"),
    .package(url: "https://github.com/eka-care/EkaMedicalRecordsCore.git", branch: "fix/document-update")
  ],
  targets: [
    .target(
      name: "EkaMedicalRecordsUI",
      dependencies: [
        .product(name: "SnapKit", package: "SnapKit"),
        .product(name: "SDWebImageSwiftUI", package: "SDWebImageSwiftUI"),
        .product(name: "EkaMedicalRecordsCore", package: "EkaMedicalRecordsCore")
      ],
      resources: [
        .process("Resources")
      ]
    )
  ]
)
