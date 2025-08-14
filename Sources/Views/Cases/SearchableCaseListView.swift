//
//  CasesListView.swift
//  EkaMedicalRecordsUI
//
//  Created by Arya Vashisht on 18/07/25.
//

import SwiftUI
import EkaUI
import EkaMedicalRecordsCore

enum CasesPresentationState {
  case casesDisplay
  case editRecord
}

struct SearchableCaseListView: View {
  
  // MARK: - Properties
  @Environment(\.managedObjectContext) private var viewContext
  @Environment(\.dismiss) private var dismiss
  @State var caseSearchText: String = ""
  @State private var isSearchActive: Bool
  let casesPresentationState: CasesPresentationState
  let recordsRepo: RecordsRepo = RecordsRepo.shared
  let onSelectCase: ((CaseModel) -> Void)?
  
  // MARK: - Init
  
  init(
    casesPresentationState: CasesPresentationState = .casesDisplay,
    isSearchActive: Bool = false,
    onSelectCase: ((CaseModel) -> Void)? = nil
  ) {
    self.casesPresentationState = casesPresentationState
    self.onSelectCase = onSelectCase
    _isSearchActive = State(initialValue: isSearchActive)
    // For preview to work
    EkaUI.registerFonts()
  }
  
  // MARK: - Body
  
  var body: some View {
    ZStack(alignment: .bottomTrailing) {
      HStack {
        List {
          QueryResponderView(
            predicate: generateCasesFetchRequest(),
            sortDescriptors: generateSortDescriptors()
          ) { (cases: FetchedResults<CaseModel>) in
            
            if !caseSearchText.isEmpty {
              NavigationLink(value: CaseFormRoute(prefilledName: caseSearchText)) {
                createNewCaseRowView()
              }
            }
            
            if cases.isEmpty {
              ContentUnavailableView(
                "No Medical Case Found",
                systemImage: "doc",
                description: Text("Create a new case to add and organize your medical records")
              )
            } else {
              ForEach(cases) { caseModel in
                itemView(caseModel)
              }
            }
          }
        }
        .listStyle(.insetGrouped)
        .searchable(
          text: $caseSearchText,
          isPresented: $isSearchActive,
          prompt: "Search or add new case"
        )
      }
      if !isSearchActive {
        EkaButtonView(
          iconImageString: "plus",
          title: "Add Case",
          size: .large,
          style: .filled,
          isEnabled: true
        ) {
          isSearchActive = true
        }
        .padding(EkaSpacing.spacingM)
      }
    }
    .frame(
      maxWidth:  .infinity,
      maxHeight: .infinity,
      alignment: .bottomTrailing
    )
    .onAppear {
      recordsRepo.getUpdatedAtAndStartCases { _ in
      }
      resetView()
    }
  }
}

// MARK: - Subviews

extension SearchableCaseListView {
  @ViewBuilder
  private func itemView(_ caseModel: CaseModel) -> some View {
    let cardView = CaseCardView(
      caseName: caseModel.caseName ?? "",
      recordCount: caseModel.toRecord?.count ?? 0,
      date: caseModel.updatedAt
    )
    
    switch casesPresentationState {
    case .casesDisplay:
      NavigationLink(value: caseModel) {
        cardView
          .contextMenu {
            Button(role: .destructive) {
              recordsRepo.deleteCase(caseModel)
            } label: {
              Text("Delete")
            }
          }
      }
      
    case .editRecord:
      cardView
        .contentShape(Rectangle())
        .onTapGesture {
          onSelectCase?(caseModel)
          dismiss()
        }
    }
  }
  
  private func createNewCaseRowView() -> some View {
    HStack(spacing: 12) {
      Circle()
        .fill(Color(.ascent))
        .frame(width: 28, height: 28)
        .overlay(
          Image(systemName: "plus")
            .foregroundColor(.white)
            .font(.system(size: 14, weight: .bold))
        )
      
      HStack(spacing: 0) {
        Text("Create new case ")
          .newTextStyle(ekaFont: .bodyRegular, color: UIColor(resource: .labelsPrimary))
        
        Text("\"\(caseSearchText)\"")
          .newTextStyle(ekaFont: .bodyEmphasized, color: UIColor(resource: .ascent))
      }
    }
    .padding(.vertical, 8)
  }
}

extension SearchableCaseListView {
  private func generateCasesFetchRequest() -> NSPredicate {
    guard let filterIDs = CoreInitConfigurations.shared.filterID else {
      return NSPredicate(value: false)
    }
    
    let oidPredicate = NSPredicate(format: "oid IN %@", filterIDs)
    let statusPredicate = NSPredicate(format: "status == %@", "A")
    
    if caseSearchText.isEmpty {
      // Only filter by IDs + active status
      return NSCompoundPredicate(andPredicateWithSubpredicates: [oidPredicate, statusPredicate])
    }
    
    let namePredicate = NSPredicate(format: "caseName CONTAINS[cd] %@", caseSearchText)
    return NSCompoundPredicate(andPredicateWithSubpredicates: [oidPredicate, statusPredicate, namePredicate])
  }
  
  func generateSortDescriptors() -> [NSSortDescriptor] {
    return [NSSortDescriptor(keyPath: \CaseModel.createdAt, ascending: true)]
  }
  
  func resetView() {
    caseSearchText = ""
  }
}

#Preview {
  SearchableCaseListView()
}

