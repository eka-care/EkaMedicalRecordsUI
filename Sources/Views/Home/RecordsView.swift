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

public struct RecordsView: View {
  
  // MARK: - Properties
  
  let recordPresentationState: RecordPresentationState
  let recordsRepo = RecordsRepo()
  @Environment(\.managedObjectContext) private var viewContext
  
  // MARK: - Init
  
  public init(
    recordPresentationState: RecordPresentationState = .displayAll
  ) {
    self.recordPresentationState = recordPresentationState
  }
  
  // MARK: - Body
  
  public var body: some View {
    switch recordPresentationState {
    case .dashboard:
      EmptyView()
    case .displayAll, .picker:
      RecordsGridListView(recordPresentationState: recordPresentationState)
        .environment(\.managedObjectContext, recordsRepo.databaseManager.container.viewContext)
    }
  }
}

#Preview {
  RecordsView()
}
