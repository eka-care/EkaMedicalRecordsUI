
# Eka Medical Records UI

## Installation

#### Swift Package Manager

The [Swift Package Manager](http:///www.swift.org/documentation/package-manager/ "Swift Package Manager") is a tool for automating the distribution of Swift code and is integrated into the swift compiler.

Add EkaMedicalRecordsUI as a dependency in your `Package.swift` file.

```swift
dependencies: [
.package(url: "https://github.com/eka-care/EkaMedicalRecordsCore.git", branch: "main")
]
```

Add `EkaMedicalRecordsUI` in the target.

```swift
.product(name: "EkaMedicalRecordsCore", package: "EkaMedicalRecordsCore")
```
