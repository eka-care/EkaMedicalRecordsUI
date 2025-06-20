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
  
  let recordsRepo: RecordsRepo
  @State var recordsFilter: [RecordDocumentType: Int] = [:]
  @Binding var selectedChip: RecordDocumentType
  @Binding var selectedSortFilter: RecordSortOptions?
  @Environment(\.managedObjectContext) private var viewContext
  
  // MARK: - Init
  
  init(
    recordsRepo: RecordsRepo,
    selectedChip: Binding<RecordDocumentType>,
    selectedSortFilter: Binding<RecordSortOptions?>
  ) {
    self.recordsRepo = recordsRepo
    _selectedChip = selectedChip
    _selectedSortFilter = selectedSortFilter
  }
  
  var body: some View {
    ChipsView()
      .onReceive(NotificationCenter.default.publisher(
        for: .NSManagedObjectContextObjectsDidChange,
        object: viewContext // must match the one being merged into
      )) { _ in
        /// Wait for merge changes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
          updateFiltersCount()
          /// if chip
          if recordsFilter[selectedChip] == nil || recordsFilter[selectedChip] == 0 {
            selectedChip = .typeAll
          }
        }
      }
  }
}

// MARK: - Subviews

extension RecordsFilterListView {
  private func ChipsView() -> some View {
    ScrollViewReader { scrollViewProxy in
      ScrollView(.horizontal, showsIndicators: false) {
        HStack {
          // Sort Button
          RecordSortMenuView(selectedOption: $selectedSortFilter)
          ForEach(RecordDocumentType.allCases.filter { recordsFilter.keys.contains($0) }, id: \.self) { chip in
            ChipView(
              selectionId: chip.intValue,
              title: getChipTitle(filter: chip),
              isSelected: selectedChip == chip
            ) { id in
              if let chipType = RecordDocumentType.from(intValue: id) {
                selectedChip = chipType
              }
            }
            .id(chip.intValue)
          }
        }
        .padding(.trailing, EkaSpacing.spacingM)
      }
      .onAppear {
        updateFiltersCount()
      }
      .onChange(of: selectedChip) { oldIndex, newIndex in
        withAnimation {
          scrollViewProxy.scrollTo(newIndex, anchor: .center)
        }
      }
    }
  }
}

// MARK: - Get count

extension RecordsFilterListView {
  private func getChipTitle(filter: RecordDocumentType) -> String {
    let filterCountString = " (\(recordsFilter[filter] ?? 0))"
    return filter.filterName + filterCountString
  }
  
  /// Update filters count
  private func updateFiltersCount() {
    recordsFilter = recordsRepo.getRecordDocumentTypeCount()
  }
}

#Preview {
  RecordsFilterListView(
    recordsRepo: RecordsRepo(),
    selectedChip: .constant(
      .typeAll
    ),
    selectedSortFilter: .constant(
      .dateOfUpload(
        sortingOrder: .newToOld
      )
    )
  )
}
