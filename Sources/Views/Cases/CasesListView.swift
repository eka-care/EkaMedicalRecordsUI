//
//  CasesListView.swift
//  EkaMedicalRecordsUI
//
//  Created by shekhar gupta on 05/08/25.
//

import SwiftUI
import EkaUI
import EkaMedicalRecordsCore

//TODO: - Shekhar optimize code
struct CasesListView: View {
  
  // MARK: - Properties
  @Environment(\.managedObjectContext) private var viewContext
  @Environment(\.dismiss) private var dismiss
  @Binding var caseSearchText: String
  @Binding var createNewCase: String?
  let casesPresentationState: CasesPresentationState
  let recordsRepo: RecordsRepo
  let onSelectCase: ((CaseModel) -> Void)?
  var shouldSelectDefaultCase: Bool = false
  @Binding var selectedCase: CaseModel?
  
  // MARK: - Init
  init(
    recordsRepo: RecordsRepo,
    casesPresentationState: CasesPresentationState = .casesDisplay,
    caseSearchText: Binding<String> = .constant(""),
    createNewCase: Binding<String?> = .constant(nil),
    selectedCase: Binding<CaseModel?> = .constant(nil),
    shouldSelectDefaultCase: Bool = false,
    onSelectCase: ((CaseModel) -> Void)? = nil,
  ) {
    self.recordsRepo = recordsRepo
    self.casesPresentationState = casesPresentationState
    self.onSelectCase = onSelectCase
    self.shouldSelectDefaultCase = shouldSelectDefaultCase
    _caseSearchText = caseSearchText
    _createNewCase = createNewCase
    _selectedCase = selectedCase
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
          
          Group {
            // Create new case row
            if !caseSearchText.isEmpty {
              if UIDevice.current.isIPad {
                CreateNewCaseRowView()
                  .onTapGesture {
                    createNewCase = caseSearchText
                  }
              } else {
                NavigationLink(value: CaseFormRoute(prefilledName: caseSearchText)) {
                  CreateNewCaseRowView()
                }
              }
            }
            
            // Content or empty state
            if cases.isEmpty {
              ContentUnavailableView(
                "No Medical Case Found",
                systemImage: "doc",
                description: Text("Create a new case to add and organize your medical records")
              )
            } else {
              // Group cases by upload month
              let groupedCases = groupCasesByMonth(Array(cases))
              
              ForEach(groupedCases.keys.sorted(by: >), id: \.self) { monthYear in
                Section(header: Text(formatSectionHeader(monthYear))) {
                  ForEach(groupedCases[monthYear] ?? []) { caseModel in
                    ItemView(caseModel)
                  }
                }
              }
            }
          }
          .onAppear {
            // Handle default case selection here
            if selectedCase == nil, shouldSelectDefaultCase, let first = cases.first {
              selectedCase = first
              onSelectCase?(first)
            }
          }
        }
      }
      .listStyle(.insetGrouped)
    }
    .frame(
      maxWidth: .infinity,
      maxHeight: .infinity,
      alignment: .topLeading
    )
    .onAppear {
      resetView()
    }
  }
}
// MARK: - Subviews

extension CasesListView {
  @ViewBuilder
  private func ItemView(_ caseModel: CaseModel) -> some View {
    let cardView = CaseCardView(
      caseName: caseModel.caseName ?? "",
      recordCount: caseModel.toRecord?.count ?? 0,
      date: caseModel.updatedAt,
      isSelected: selectedCase?.caseID == caseModel.caseID
    )
    
    switch casesPresentationState {
    case .casesDisplay:
          cardView
            .contextMenu {
              Button(role: .destructive) {
                recordsRepo.deleteCase(caseModel)
              } label: {
                Text("Archive")
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
  
  private func CreateNewCaseRowView() -> some View {
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

extension CasesListView {
  private func generateCasesFetchRequest() -> NSPredicate {
    guard let filterIDs = CoreInitConfigurations.shared.filterID else {
      return NSPredicate(value: false)
    }
    let oidPredicate = NSPredicate(format: "oid IN %@", filterIDs)
    if caseSearchText.isEmpty {
      return oidPredicate
    }
    let namePredicate = NSPredicate(format: "caseName CONTAINS[cd] %@", caseSearchText)
    return NSCompoundPredicate(andPredicateWithSubpredicates: [oidPredicate, namePredicate])
  }
  
  func generateSortDescriptors() -> [NSSortDescriptor] {
    return [NSSortDescriptor(keyPath: \CaseModel.createdAt, ascending: true)]
  }
  
  func resetView() {
    caseSearchText = ""
  }
}

extension CasesListView {
  
  // Helper function to group cases by month and year
  private func groupCasesByMonth(_ cases: [CaseModel]) -> [Date: [CaseModel]] {
    let calendar = Calendar.current
    
    return Dictionary(grouping: cases) { caseModel in
      // Assuming CaseModel has a createdDate or uploadDate property
      let date = caseModel.createdAt ?? Date()
      
      // Get the start of the month for grouping
      return calendar.dateInterval(of: .month, for: date)?.start ?? date
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
  CasesListView(recordsRepo: RecordsRepo())
}
