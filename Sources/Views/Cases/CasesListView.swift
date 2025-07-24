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
  @State var caseSearchText: String = ""
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
      List {
        QueryResponderView(
          predicate: generateCasesFetchRequest(),
          sortDescriptors: generateSortDescriptors()
        ) { (cases: FetchedResults<CaseModel>) in
          ForEach(cases) { caseModel in
            ItemView(caseModel)
          }
        }
      }
      .listStyle(.insetGrouped)
      
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
    .searchable(
      text: $caseSearchText,
      prompt: "Search or add new case"
    )
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

// MARK: - Subviews

extension CasesListView {
  private func ItemView(_ caseModel: CaseModel) -> some View {
    NavigationLink(value: caseModel) {
      CaseCardView(
        caseName: caseModel.caseName ?? "",
        recordCount: caseModel.toRecord?.count ?? 0,
        date: caseModel.updatedAt
      )
      .contextMenu {
        Button(role: .destructive) {
          recordsRepo.deleteCase(caseModel)
        } label: {
          Text("Delete")
        }
      }
    }
  }
}

extension CasesListView {
  private func generateCasesFetchRequest() -> NSPredicate {
    //    guard let filterIDs = CoreInitConfigurations.shared.filterID else { return NSPredicate(value: false) }
    //    return NSPredicate(format: "oid IN %@", filterIDs)
    guard !caseSearchText.isEmpty else {
      return NSPredicate(value: true)
    }
    return NSPredicate(format: "caseName CONTAINS[cd] %@", caseSearchText)
  }
  
  func generateSortDescriptors() -> [NSSortDescriptor] {
    return [NSSortDescriptor(keyPath: \CaseModel.createdAt, ascending: true)]
  }
}

#Preview {
  CasesListView(recordsRepo: RecordsRepo())
}
