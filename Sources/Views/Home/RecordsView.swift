//
//  RecordView.swift
//  EkaMedicalRecordsUI
//
//  Created by Arya Vashisht on 28/01/25.
//

import SwiftUI
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

public struct RecordsView: View {
  
  // MARK: - Properties
  
  public let recordPresentationState: RecordPresentationState
  let recordsRepo: RecordsRepo
  @Environment(\.managedObjectContext) private var viewContext
  /// Used for callback when picker does select images
  var didSelectPickerDataObjects: RecordItemsCallback
  
  // MARK: - Init
  
  public init(
    recordsRepo: RecordsRepo,
    recordPresentationState: RecordPresentationState = .displayAll,
    didSelectPickerDataObjects: RecordItemsCallback = nil
  ) {
    self.recordsRepo = recordsRepo
    self.recordPresentationState = recordPresentationState
    self.didSelectPickerDataObjects = didSelectPickerDataObjects
  }
  
  // MARK: - Body
  
  public var body: some View {
      switch recordPresentationState {
      case .dashboard, .caseRelatedRecordsView:
        EmptyView()
      case .displayAll, .picker:
        RecordsGridListView(
          recordsRepo: recordsRepo,
          recordPresentationState: recordPresentationState,
          didSelectPickerDataObjects: didSelectPickerDataObjects,
          title: recordPresentationState.title,
          pickerSelectedRecords: .constant([])
        )
        .environment(\.managedObjectContext, viewContext)
      }
  }
}

#Preview {
  RecordsView(recordsRepo: RecordsRepo())
}
