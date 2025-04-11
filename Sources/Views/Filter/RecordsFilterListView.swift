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
  
  @Binding var selectedChip: RecordDocumentType
  
  // MARK: - Init
  
  init(
    selectedChip: Binding<RecordDocumentType>
  ) {
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
          ForEach(RecordDocumentType.allCases, id: \.self) { chip in
            ChipView(
              selectionId: chip.intValue,
              title: chip.filterName,
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
      .onChange(of: selectedChip) { oldIndex, newIndex in
        withAnimation {
          scrollViewProxy.scrollTo(newIndex, anchor: .center)
        }
      }
    }
  }
}

#Preview {
  RecordsFilterListView(selectedChip: .constant(.typeAll))
}
