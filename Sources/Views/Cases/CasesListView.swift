//
//  CasesListView.swift
//  EkaMedicalRecordsUI
//
//  Created by shekhar gupta on 05/08/25.
//

import SwiftUI
import EkaUI
import EkaMedicalRecordsCore

struct CasesListView: View {
  
  // MARK: - Properties
  @Environment(\.managedObjectContext) private var viewContext
  @Environment(\.dismiss) private var dismiss
  @Binding var caseSearchText: String
  @Binding var createNewCase: String?
  private let casesPresentationState: CasesPresentationState
  private let recordsRepo: RecordsRepo = RecordsRepo.shared
  private let onSelectCase: ((CaseModel) -> Void)?
  private var shouldSelectDefaultCase: Bool = false
  @Binding var selectedCase: CaseModel?
  
  // MARK: - Init
  init(
    casesPresentationState: CasesPresentationState = .casesDisplay,
    caseSearchText: Binding<String> = .constant(""),
    createNewCase: Binding<String?> = .constant(nil),
    selectedCase: Binding<CaseModel?> = .constant(nil),
    shouldSelectDefaultCase: Bool = false,
    onSelectCase: ((CaseModel) -> Void)? = nil,
  ) {
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
            if !caseSearchText.isEmpty && !CoreInitConfigurations.shared.blockedFeatureTypes.contains(.createMedicalRecordsCases) {
              if UIDevice.current.isIPad {
                createNewCaseRowView()
                  .onTapGesture {
                    createNewCase = caseSearchText
                  }
              } else {
                NavigationLink(value: CaseFormRoute(prefilledName: caseSearchText)) {
                  createNewCaseRowView()
                }
              }
            }
            
            // Content or empty state
            if cases.isEmpty {
              ContentUnavailableView(
                "No Encounters",
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
  private func itemView(_ caseModel: CaseModel) -> some View {
    let cardView = CaseCardView(
      caseName: caseModel.caseName ?? "",
      recordCount: caseModel.toRecord?.count ?? 0,
      date: caseModel.updatedAt,
      caseTypeEnum: CaseTypesEnum.getCaseType(for: caseModel.caseType ?? ""),
      isSelected: selectedCase?.caseID == caseModel.caseID
    )
    
    switch casesPresentationState {
    case .casesDisplay:
      if UIDevice.current.isIPad {
        cardView
          .contextMenu {
            Button(role: .destructive) {
              recordsRepo.deleteCase(caseModel)
            } label: {
              Text("Archive")
            }
          }
          .contentShape(Rectangle())
          .onTapGesture {
            selectedCase = caseModel
            onSelectCase?(caseModel)
        }
      } else {
        cardView
          .contextMenu {
            Button(role: .destructive) {
              recordsRepo.deleteCase(caseModel)
            } label: {
              Text("Archive")
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

extension CasesListView {
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

extension CasesListView {
  
  // Helper function to group cases by month and year
  private func groupCasesByMonth(_ cases: [CaseModel]) -> [Date: [CaseModel]] {
    let calendar = Calendar.current
    
    let grouped = Dictionary(grouping: cases) { caseModel in
      // Assuming CaseModel has a createdDate or uploadDate property
      let date = caseModel.updatedAt ?? Date()
      
      // Get the start of the month for grouping
      return calendar.dateInterval(of: .month, for: date)?.start ?? date
    }
    
    // Sort cases within each month by date in descending order
    return grouped.mapValues { cases in
      cases.sorted { (case1, case2) in
        let date1 = case1.updatedAt ?? Date()
        let date2 = case2.updatedAt ?? Date()
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
  CasesListView()
}
