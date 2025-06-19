//
//  RecordSortMenuView.swift
//  EkaMedicalRecordsUI
//
//  Created by Arya Vashisht on 19/06/25.
//

import SwiftUI

struct RecordSortMenuView: View {
  @State private var selectedOption: RecordSortOptions?
  
  var body: some View {
    Menu {
      ForEach(RecordSortOptions.allCases, id: \.self) { option in
        Button {
          selectedOption = option
        } label: {
          HStack {
            Text(option.title)
              .textStyle(ekaFont: .bodyRegular, color: .black)
            if option == selectedOption {
              Image(systemName: "checkmark")
                .resizable()
                .scaledToFit()
                .frame(width: 12, height: 12, alignment: .center)
            }
          }
        }
      }
    } label: {
      ChipView(
        selectionId: 0,
        title: getChipTitle(),
        image: selectedOption == nil ? UIImage(systemName: "chevron.down") : nil,
        isSelected: selectedOption != nil
      ) {_ in}
    }
  }
}

extension RecordSortMenuView {
  func getChipTitle() -> String {
    selectedOption?.title ?? "Sort"
  }
}
