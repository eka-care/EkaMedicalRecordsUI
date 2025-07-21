//
//  CasesListView.swift
//  EkaMedicalRecordsUI
//
//  Created by Arya Vashisht on 18/07/25.
//

import SwiftUI
import EkaUI
import EkaMedicalRecordsCore

struct CasesListView: View {
  
  // MARK: - Properties
  
  @Environment(\.managedObjectContext) private var viewContext
  @State var isCreateCaseFormSheetOpened: Bool = false
  let recordsRepo: RecordsRepo
  
  // MARK: - Init
  
  init(
    recordsRepo: RecordsRepo
  ) {
    self.recordsRepo = recordsRepo
    // For preview to work
    EkaUI.registerFonts()
  }
  
  // MARK: - Body
  
  var body: some View {
    ZStack(alignment: .bottomTrailing) {
      ScrollView {
        QueryResponderView(
          predicate: generateCasesFetchRequest(),
          sortDescriptors: generateSortDescriptors()
        ) { (cases: FetchedResults<CaseModel>) in
          VStack(alignment: .leading) {
            ForEach(cases) { caseModel in
              if let caseName = caseModel.caseName {
                Text(caseName)
              }
            }
          }
        }
      }
      
      EkaButtonView(
        iconImageString: "plus",
        title: "Add Case",
        size: .large,
        style: .filled,
        isEnabled: true
      ) {
        isCreateCaseFormSheetOpened = true
      }
      .padding(EkaSpacing.spacingM)
    }
    .frame(
      maxWidth:  .infinity,
      maxHeight: .infinity,
      alignment: .bottomTrailing
    )
    .sheet(isPresented: $isCreateCaseFormSheetOpened) {
      CreateCaseFormView(recordsRepo: recordsRepo)
    }
  }
}

extension CasesListView {
  private func generateCasesFetchRequest() -> NSPredicate {
//    guard let filterIDs = CoreInitConfigurations.shared.filterID else { return NSPredicate(value: false) }
//    return NSPredicate(format: "oid IN %@", filterIDs)
    return NSPredicate(value: true)
  }
  
  func generateSortDescriptors() -> [NSSortDescriptor] {
    return [NSSortDescriptor(keyPath: \CaseModel.createdAt, ascending: true)]
  }
}

#Preview {
  CasesListView(recordsRepo: RecordsRepo())
}
