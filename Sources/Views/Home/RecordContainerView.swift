//
//  RecordContainerView.swift
//  EkaMedicalRecordsUI
//
//  Created by Arya Vashisht on 18/07/25.
//

import SwiftUI
import EkaUI
import EkaMedicalRecordsCore

public enum RecordPresentationState: Equatable {
  case dashboard /// Full medical records dashboard state
  case displayAll /// Display All medical records state
  case picker /// Medical records picker state
  case caseRelatedRecordsView(caseID: String?) /// Medical records related to a case
  
  var title: String {
    switch self {
    case .dashboard:
      return ""
    case .displayAll:
      return InitConfiguration.shared.recordsTitle ?? "All"
    case .picker:
      return InitConfiguration.shared.recordsTitle ?? "Select"
    case .caseRelatedRecordsView:
      return "Documents"
    }
  }
  
  var isCaseRelated: Bool {
    if case .caseRelatedRecordsView = self {
      return true
    }
    return false
  }
  
  var associatedCaseID: String? {
    if case let .caseRelatedRecordsView(caseID) = self {
      return caseID
    }
    return nil
  }
}

public typealias RecordItemsCallback = (([RecordPickerDataModel]) -> Void)?

enum RecordTab: CaseIterable, Hashable {
  case records
  case cases
  
  var title: String {
    switch self {
    case .records:
      return "All files"
    case .cases:
      return "Medical Cases"
    }
  }
}

public struct RecordContainerView: View {
  @State private var selectedTab: RecordTab = .records
  @State var pickerSelectedRecords: [Record] = []
  /// Used to display downloading loader in view
  @State private var isDownloading: Bool = false
  @Environment(\.dismiss) private var dismiss
  let recordsRepo = RecordsRepo()
  /// Used for callback when picker does select images
  var didSelectPickerDataObjects: RecordItemsCallback
  var recordPresentationState: RecordPresentationState
  
  public init(
    didSelectPickerDataObjects: RecordItemsCallback = nil,
    recordPresentationState: RecordPresentationState = .displayAll
  ) {
    self.didSelectPickerDataObjects = didSelectPickerDataObjects
    self.recordPresentationState = recordPresentationState
    // For preview to work
    EkaUI.registerFonts()
  }
  
  public var body: some View {
    VStack {
      SegmentsView()
      contentView()
    }
    .navigationDestination(for: CaseModel.self) { model in
      RecordsGridListView(
        recordsRepo: recordsRepo,
        recordPresentationState: .caseRelatedRecordsView(caseID: model.caseID),
        title: model.caseName ?? "Documents"
      )
      .environment(\.managedObjectContext, recordsRepo.databaseManager.container.viewContext)
    }
    .navigationDestination(for: CaseFormRoute.self) { route in
      CreateCaseFormView(
        caseName: route.prefilledName,
        recordsRepo: recordsRepo
      )
      .environment(\.managedObjectContext, recordsRepo.databaseManager.container.viewContext)
    }
    .navigationDestination(for: Record.self) { record in
      RecordView(record: record)
    }
    .navigationTitle(InitConfiguration.shared.recordsTitle ?? recordPresentationState.title) // Add a navigation title
    .toolbar { /// Toolbar item
      /// Close button on the top left
      ToolbarItem(placement: .topBarLeading) {
        Button(action: {
          /// Dismiss or handle close action
          dismiss()
        }) {
          Text("Close")
            .textStyle(ekaFont: .bodyRegular, color: UIColor(resource: .primary500))
        }
      }
      
      ToolbarItem(placement: .topBarTrailing) {
        // Done button
        if pickerSelectedRecords.count > 0 {
          Button("Done") {
            onDoneButtonPressed()
          }
        }
      }
    }
  }
}

// MARK: - Subview

extension RecordContainerView {
  @ViewBuilder
  private func contentView() -> some View {
    switch selectedTab {
    case .records:
      RecordsGridListView(
        recordsRepo: recordsRepo,
        recordPresentationState: recordPresentationState,
        title: recordPresentationState.title,
        pickerSelectedRecords: $pickerSelectedRecords
      )
      .environment(\.managedObjectContext, recordsRepo.databaseManager.container.viewContext)
    case .cases:
      CasesListView(recordsRepo: recordsRepo)
        .environment(\.managedObjectContext, recordsRepo.databaseManager.container.viewContext)
    }
  }
  
  private func SegmentsView() -> some View {
    VStack {
      Picker("", selection: $selectedTab) {
        ForEach(RecordTab.allCases, id: \.self) { tabType in
          Text(tabType.title)
            .newTextStyle(ekaFont: .footnoteEmphasized, color: UIColor(resource: .labelsPrimary))
        }
      }
      .pickerStyle(SegmentedPickerStyle())
    }
  }
}

extension RecordContainerView {
  /// On press of done button in picker state
  private func onDoneButtonPressed() {
    dismiss()
    isDownloading = true
    setPickerSelectedObjects(selectedRecords: pickerSelectedRecords) { pickedRecords in
      isDownloading = false
      didSelectPickerDataObjects?(pickedRecords)
    }
  }
  
  /// Get picker selected images from records
  private func setPickerSelectedObjects(
    selectedRecords: [Record],
    completion: RecordItemsCallback
  ) {
    var pickerObjects: [RecordPickerDataModel] = []
    recordsRepo.fetchRecordsMetaData(for: selectedRecords) { documentURIs in
      for (index, value) in selectedRecords.enumerated() {
        pickerObjects.append(
          RecordPickerDataModel(
            image: value.thumbnail,
            documentID: value.documentID,
            documentPath: documentURIs[index]
          )
        )
      }
      completion?(pickerObjects)
    }
  }
}

#Preview {
  RecordContainerView()
}
