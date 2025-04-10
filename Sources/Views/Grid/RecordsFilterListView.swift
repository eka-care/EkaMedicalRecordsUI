//
//  RecordsFilterListView.swift
//  EkaMedicalRecordsUI
//
//  Created by Arya Vashisht on 09/04/25.
//

import SwiftUI
import EkaMedicalRecordsCore

struct RecordsFilterListView: View {
  
//  @State private var selectedChip: RecordDocumentType = 
  
  var body: some View {
    Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
  }
}

// MARK: - Subviews

extension RecordsFilterListView {
  private func ChipsView() -> some View {
    HStack {
//      ForEach(ChipType.allCases, id: \.self) { chip in
//        ChipView(
//          selectionId: chip.rawValue,
//          title: chip.formChipTitle(count: getCount(chip: chip)),
//          isSelected: selectedChip == chip
//        ) { id in
//          if let chipType = ChipType(rawValue: id) {
//            selectedChip = chipType
//          }
//        }
//      }
//      Spacer()
    }
  }
}

#Preview {
  RecordsFilterListView()
}
