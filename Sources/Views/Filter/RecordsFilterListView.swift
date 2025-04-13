//
//  RecordsFilterListView.swift
//  EkaMedicalRecordsUI
//
//  Created by Arya Vashisht on 10/04/25.
//


import SwiftUI
import EkaMedicalRecordsCore

struct RecordsFilterListView: View {
  
  // MARK: - Properties
  
  let recordsRepo: RecordsRepo
  @State var recordsFilter: [RecordDocumentType: Int] = [:]
  @Binding var selectedChip: RecordDocumentType
  
  // MARK: - Init
  
  init(
    recordsRepo: RecordsRepo,
    selectedChip: Binding<RecordDocumentType>
  ) {
    self.recordsRepo = recordsRepo
    _selectedChip = selectedChip
  }
  
  var body: some View {
    ChipsView()
  }
}

// MARK: - Subviews

extension RecordsFilterListView {
  private func ChipsView() -> some View {
    ScrollViewReader { scrollViewProxy in
      ScrollView(.horizontal, showsIndicators: false) {
        HStack {
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
        recordsFilter = recordsRepo.getRecordDocumentTypeCount()
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
}

#Preview {
  RecordsFilterListView(recordsRepo: RecordsRepo(), selectedChip: .constant(.typeAll))
}
