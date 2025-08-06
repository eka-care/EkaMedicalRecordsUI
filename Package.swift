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
    .package(url: "https://github.com/eka-care/EkaMedicalRecordsCore.git", branch: "main"),
    .package(url: "git@github.com:eka-care/EkaUI.git", branch: "main")
  ],
  targets: [
    .target(
      name: "EkaMedicalRecordsUI",
      dependencies: [
        .product(name: "EkaMedicalRecordsCore", package: "EkaMedicalRecordsCore"),
        .product(name: "EkaUI", package: "EkaUI")
      ],
      resources: [
        .process("Resources")
      ]
    )
  ]
)
