//
//  RecordsFilterListView.swift
//  EkaMedicalRecordsUI
//
//  Created by Arya Vashisht on 10/04/25.
//

import SwiftUI
import EkaMedicalRecordsCore
import Combine

struct RecordsFilterListView: View {
  // MARK: - Properties
  private let recordsRepo: RecordsRepo = RecordsRepo.shared
  @State var recordsFilter: [String: Int] = [:]
  @Binding var selectedChip: [String]
  @Binding var selectedDocType: String?
  @Binding var selectedSortFilter: RecordSortOptions?
  @Binding var caseID: String?
  @Environment(\.managedObjectContext) private var viewContext
  
  // MARK: - Init
  init(
    selectedChip: Binding<[String]>,
    selectedSortFilter: Binding<RecordSortOptions?>,
    caseID: Binding<String?>,
    selectedDocType: Binding<String?>
  ) {
    _caseID = caseID
    _selectedChip = selectedChip
    _selectedSortFilter = selectedSortFilter
    _selectedDocType = selectedDocType
  }
  
  var body: some View {
    chipsView()
      .onReceive(NotificationCenter.default.publisher(
        for: .NSManagedObjectContextObjectsDidChange,
        object: viewContext
      )) { _ in
        refreshFilters()
      }
      .onChange(of: caseID) { _, _ in
        refreshFilters()
      }
  }
}

// MARK: - Subviews
extension RecordsFilterListView {
  private func chipsView() -> some View {
    ScrollViewReader { scrollViewProxy in
      ScrollView(.horizontal, showsIndicators: false) {
        HStack {
          // Sort Button
          RecordSortMenuView(selectedOption: $selectedSortFilter)
          // Doc Type Button
          RecordDocTypeMenuView(selectedDocType: $selectedDocType, caseId: $caseID)

          ForEach(
            recordsFilter.sorted(by: { lhs, rhs in
              let lhsSelected = selectedChip.contains(lhs.key)
              let rhsSelected = selectedChip.contains(rhs.key)

              if lhsSelected && !rhsSelected { return true }
              if !lhsSelected && rhsSelected { return false }

              if lhsSelected && rhsSelected {
                let lhsIndex = selectedChip.firstIndex(of: lhs.key) ?? 0
                let rhsIndex = selectedChip.firstIndex(of: rhs.key) ?? 0
                return lhsIndex < rhsIndex
              }

              return lhs.value > rhs.value
            }),
            id: \.key
          ) { key, value in
            ChipView(
              selectionId: key,
              title: getChipTitle(filterId: key),
              isSelected: selectedChip.contains(key)
            ) { _ in
              withAnimation(.easeInOut) {
                if selectedChip.contains(key) {
                  selectedChip.removeAll { $0 == key }
                } else {
                  selectedChip.append(key)   
                }
              }
            }
            .id(key)
          }
          .animation(.easeInOut, value: selectedChip)
        }
        .padding(.trailing, EkaSpacing.spacingM)
      }
      .onAppear {
        updateFiltersCount()
      }
      .onChange(of: selectedChip) { _, newSelection in
        withAnimation {
          if let first = newSelection.first {
            scrollViewProxy.scrollTo(first, anchor: .center)
          }
        }
      }
      .onChange(of: selectedDocType) { _, _ in
        selectedChip.removeAll()
        updateFiltersCount()
      }
    }
  }
}

// MARK: - Helpers
extension RecordsFilterListView {
  private func getChipTitle(filterId: String) -> String {
    let filterDisplayName = documentTypesList.first(where: { data in
      data.id == filterId
    })?.filterName ?? filterId

    let filterCountString = " (\(recordsFilter[filterId] ?? 0))"
    return filterDisplayName + filterCountString
  }

  private func refreshFilters() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      updateFiltersCount()
    }
  }

  private func updateFiltersCount() {
//    let filtersDocType = recordsRepo.getRecordDocumentTypeCount(caseID: caseID)
    recordsFilter = recordsRepo.getRecordTagCount(caseID: caseID, documentType: selectedDocType)

    //  Auto-cleanup: remove chips that no longer exist or are zero
    selectedChip.removeAll { key in
      recordsFilter[key] == nil || recordsFilter[key] == 0
    }

    if selectedChip.isEmpty {
      selectedChip = []
    }
  }
}

#Preview {
  RecordsFilterListView(
    selectedChip: .constant([]),
    selectedSortFilter: .constant(
      .dateOfUpload(sortingOrder: .newToOld)
    ),
    caseID: .constant(nil),
    selectedDocType: .constant(nil)
  )
}
