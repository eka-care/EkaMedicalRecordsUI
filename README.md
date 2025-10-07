
# Eka Medical Records UI

A flexible, customizable SwiftUI SDK for displaying and managing medical records in iOS applications.

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

## Quick Start

### Basic Usage

```swift
import EkaMedicalRecordsUI

// Display all records with default UI
let recordsView = RecordContainerView(
    recordPresentationState: .displayAll,
    uiConfiguration: .default
)
```

### Customizing the UI

The SDK provides a powerful `UIConfiguration` system to customize the appearance and behavior:

```swift
let customConfig = UIConfiguration(
    showCloseButton: false,
    customTitle: "Patient Records",
    showFilterOptions: true,
    showSearchBar: true
)

let recordsView = RecordContainerView(
    recordPresentationState: .displayAll,
    uiConfiguration: customConfig
)
```

### Using Preset Configurations

```swift
// Minimal UI
RecordContainerView(uiConfiguration: .minimal)

// Picker mode
RecordContainerView(
    recordPresentationState: .picker(maxCount: 5),
    uiConfiguration: .pickerOnly,
    didSelectPickerDataObjects: { records in
        // Handle selected records
    }
)

// Dashboard mode
RecordContainerView(
    recordPresentationState: .dashboard,
    uiConfiguration: .dashboard
)
```

## Features

- 📱 **Responsive Design**: Optimized for both iPhone and iPad
- 🎨 **Customizable UI**: Extensive configuration options for appearance and behavior
- 🔍 **Search & Filter**: Built-in search and filtering capabilities
- 📂 **Case Management**: Organize records by medical cases/encounters
- ✅ **Record Selection**: Picker mode for selecting multiple records
- 🔄 **Auto-Sync**: Automatic syncing with backend services
- 📊 **Dashboard Mode**: Read-only view for dashboards
- 🌐 **Offline Support**: Works seamlessly offline

## Configuration Options

The SDK provides three levels of configuration:

### 1. InitConfiguration (Singleton)
Global SDK configuration for data and resources:

```swift
InitConfiguration.shared.recordsTitle = "Medical Records"
InitConfiguration.shared.helper = MyDocumentHelper()
```

### 2. RecordPresentationState
Controls the mode and filters:

```swift
// Display all records
RecordPresentationState(mode: .displayAll)

// Dashboard mode
RecordPresentationState(mode: .dashboard)

// Picker mode with max selection
RecordPresentationState(mode: .picker(maxCount: 5))

// Copy vitals mode
RecordPresentationState(mode: .copyVitals)

// With filters
RecordPresentationState(
    mode: .displayAll,
    filters: RecordFilter(caseID: "case123", tags: ["lab", "imaging"])
)
```

### 3. UIConfiguration
Customizes UI appearance and behavior:

- Navigation controls (close button, refresh, done button)
- Tab visibility and default tab
- Search and filter options
- Display preferences (titles, counts, timestamps)
- Case management features
- iPad-specific layouts

**See [UI_CONFIGURATION_GUIDE.md](UI_CONFIGURATION_GUIDE.md) for comprehensive documentation.**

## Common Use Cases

### 1. Embedded in Existing Navigation

```swift
NavigationStack {
    RecordContainerView(
        recordPresentationState: .displayAll,
        uiConfiguration: UIConfiguration(
            showCloseButton: false,
            customTitle: "Health Records"
        )
    )
}
```

### 2. Record Selection

```swift
RecordContainerView(
    recordPresentationState: .picker(maxCount: 3),
    uiConfiguration: .pickerOnly,
    didSelectPickerDataObjects: { selectedRecords in
        print("Selected \(selectedRecords.count) records")
        // Process selected records
    }
)
```

### 3. Dashboard Widget

```swift
RecordContainerView(
    recordPresentationState: .dashboard,
    uiConfiguration: UIConfiguration(
        showCloseButton: false,
        showRefreshButton: true,
        showLastUpdatedTime: true
    )
)
```

### 4. Records Only (No Cases)

```swift
RecordContainerView(
    uiConfiguration: UIConfiguration(
        availableTabs: [.records],
        showTabSelector: false,
        allowCaseCreation: false,
        showCaseFeatures: false
    )
)
```

## Documentation

- **[UI Configuration Guide](UI_CONFIGURATION_GUIDE.md)** - Comprehensive guide to UI customization
- **[UIConfiguration+Examples.swift](Sources/Configurations/UIConfiguration+Examples.swift)** - Code examples and reference

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+

## Support

For issues, questions, or feature requests, please contact the SDK team or refer to the documentation.
