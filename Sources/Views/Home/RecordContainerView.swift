//
//  RecordContainerView.swift
//  EkaMedicalRecordsUI
//
//  Created by Arya Vashisht on 18/07/25.
//

import SwiftUI
import EkaUI
import EkaMedicalRecordsCore

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
  let recordsRepo = RecordsRepo()
  
  public init() {
    // For preview to work
    EkaUI.registerFonts()
  }
  public var body: some View {
    SegmentsView()
    contentView()
  }
}

// MARK: - Subview

extension RecordContainerView {
  @ViewBuilder
  private func contentView() -> some View {
    switch selectedTab {
    case .records:
      RecordsGridListView(recordsRepo: recordsRepo, recordPresentationState: .displayAll, title: RecordPresentationState.displayAll.title)
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

#Preview {
  RecordContainerView()
}
