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
  private let casesPresentationState: CasesPresentationState
  private let recordsRepo: RecordsRepo = RecordsRepo.shared
  private let onSelectCase: ((CaseModel) -> Void)?
  
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
            
            if !caseSearchText.isEmpty  && !CoreInitConfigurations.shared.blockedFeatureTypes.contains(.createMedicalRecordsCases){
              NavigationLink(value: CaseFormRoute(prefilledName: caseSearchText)) {
                createNewCaseRowView()
              }
            }
            
            if cases.isEmpty {
              ContentUnavailableView(
                "No Encounter Found",
                systemImage: "doc",
                description: Text("Create a new Encounter to add and organize your medical records")
              )
            } else {
              // Group cases by upload month
              let groupedCases = groupCasesByMonth(Array(cases))
              
              ForEach(groupedCases.keys.sorted(by: >), id: \.self) { monthYear in
                Section(header: Text(formatSectionHeader(monthYear))) {
                  ForEach(groupedCases[monthYear] ?? []) { caseModel in
                    itemView(caseModel)
                  }
                }
              }
            }
          }
        }
        .listStyle(.insetGrouped)
        .searchable(
          text: $caseSearchText,
          isPresented: $isSearchActive,
          prompt: "Search or add an encounter"
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
      date: caseModel.occuredAt,
      caseTypeEnum: CaseTypesEnum.getCaseType(for: caseModel.caseType ?? "")
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
        Text("Create an encounter ")
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
    return [NSSortDescriptor(keyPath: \CaseModel.occuredAt, ascending: true)]
  }
  
  func resetView() {
    caseSearchText = ""
  }
}


extension SearchableCaseListView {
  
  // Helper function to group cases by month and year
  private func groupCasesByMonth(_ cases: [CaseModel]) -> [Date: [CaseModel]] {
    let calendar = Calendar.current
    
    let grouped = Dictionary(grouping: cases) { caseModel in
      // Assuming CaseModel has a createdDate or uploadDate property
      let date = caseModel.occuredAt ?? Date()
      
      // Get the start of the month for grouping
      return calendar.dateInterval(of: .month, for: date)?.start ?? date
    }
    
    // Sort cases within each month by date in descending order
    return grouped.mapValues { cases in
      cases.sorted { (case1, case2) in
        let date1 = case1.occuredAt ?? Date()
        let date2 = case2.occuredAt ?? Date()
        return date1 > date2 // Descending order (newest first)
      }
    }
  }
  
  // Helper function to format section headers
  private func formatSectionHeader(_ date: Date) -> String {
    let calendar = Calendar.current
    let now = Date()
    
    // Check if it's the current month
    if calendar.isDate(date, equalTo: now, toGranularity: .month) {
      return "This Month"
    }
    
    // Format as "Month Year" for other months
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM yyyy"
    return formatter.string(from: date)
  }
}

#Preview {
  SearchableCaseListView()
}

