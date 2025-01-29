//
//  SwiftUIView.swift
//  EkaMedicalRecordsUI
//
//  Created by Arya Vashisht on 28/01/25.
//

import SwiftUI
import EkaMedicalRecordsCore

public enum RecordPresentationState {
  case dashboard /// Full medical records dashboard state
  case displayAll /// Display All medical records state
  case picker /// Medical records picker state
  
  var title: String {
    switch self {
    case .dashboard:
      return ""
    case .displayAll:
      return ""
    case .picker:
      return "Select"
    }
  }
}

public typealias PickerImagesCallback = (([UIImage]) -> Void)?

public struct RecordsView: View {
  
  // MARK: - Properties
  
  public let recordPresentationState: RecordPresentationState
  let recordsRepo = RecordsRepo()
  @Environment(\.managedObjectContext) private var viewContext
  /// Used for callback when picker does select images
  var didSelectPickerImages: PickerImagesCallback
  
  // MARK: - Init
  
  public init(
    recordPresentationState: RecordPresentationState = .displayAll,
    didSelectPickerImages: PickerImagesCallback = nil
  ) {
    self.recordPresentationState = recordPresentationState
    self.didSelectPickerImages = didSelectPickerImages
  }
  
  // MARK: - Body
  
  public var body: some View {
    switch recordPresentationState {
    case .dashboard:
      EmptyView()
    case .displayAll, .picker:
      RecordsGridListView(
        recordPresentationState: recordPresentationState
      )
      .environment(\.managedObjectContext, recordsRepo.databaseManager.container.viewContext)
    }
  }
}

#Preview {
  RecordsView()
}
